import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../sph_repository.dart';
import '../template_repository.dart';
import '../master_template_repository.dart';
import '../../models/template.dart';
import '../../models/sph.dart';
import '../../models/sph_item.dart';

class ExcelService {
  static Future<void> export(BuildContext context, int sphId) async {
    try {
      final sphRepo = SphRepository();
      final sph = await sphRepo.getById(sphId);
      final items = await sphRepo.getItems(sphId);
      if (sph == null) return;

      final templateRepo = MasterTemplateRepository();
      final template = await templateRepo.getActive();

      if (template != null) {
        final (hasMapping, missingFields, filled) = await templateRepo.isMappingComplete();
        final total = filled + missingFields.length;
        if (hasMapping) {
          if (missingFields.isNotEmpty && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$filled dari $total field terisi. Field tanpa mapping akan dilewati.'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          await _exportWithTemplate(context, sph, items, template, templateRepo);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Belum ada mapping field. Export tanpa template.'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          await _exportFromScratch(context, sph, items);
        }
      } else {
        await _exportFromScratch(context, sph, items);
      }
    } catch (e) {
      debugPrint('Excel Export Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export Excel: $e')),
        );
      }
    }
  }

  static Future<void> _exportWithTemplate(
    BuildContext context, Sph sph, List<SphItem> items,
    MasterTemplate template, MasterTemplateRepository templateRepo,
  ) async {
    final file = File(template.filePath);
    if (!await file.exists()) {
      await _exportFromScratch(context, sph, items);
      return;
    }

    final bytes = await file.readAsBytes();
    final excel = excel_lib.Excel.decodeBytes(bytes);
    final sheetName = template.sheetName ?? excel.tables.keys.first;
    final sheet = excel[sheetName];

    final mappings = await templateRepo.getAllMappings();
    final headerMappings = mappings.where((m) => m.isTableField == 0).toList();
    final tableMappings = mappings.where((m) => m.isTableField == 1).toList();

    _insertTableRows(sheet, items, tableMappings, headerMappings);

    for (final m in headerMappings) {
      if (m.cellAddress == null || m.cellAddress!.isEmpty) continue;
      final value = _getHeaderFieldValue(sph, m.fieldName);
      if (value != null) {
        _writeCell(sheet, m.cellAddress!, value);
      }
    }

    if (items.isNotEmpty && tableMappings.isNotEmpty) {
      _writeTableData(sheet, items, tableMappings);
    }

    _writeTotals(sheet, sph, headerMappings);

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${sph.number}.xlsx';
    final saved = excel.save();
    if (saved != null) {
      await File(filePath).writeAsBytes(saved);
      await OpenFile.open(filePath);
    }
  }

  static String? _getHeaderFieldValue(Sph sph, String fieldName) {
    switch (fieldName) {
      case 'sph_number': return sph.number;
      case 'sph_date': return sph.date;
      case 'perihal': return sph.title;
      case 'customer_name': return sph.customerName;
      case 'customer_company': return sph.customerCompany;
      case 'customer_address': return sph.customerAddress;
      case 'customer_pic': return sph.customerPic;
      case 'ship_name': return sph.shipName;
      case 'validity_period': return sph.validityPeriod;
      case 'notes': return sph.notes;
      case 'total_material': return _formatNumber(sph.totalMaterial);
      case 'total_jasa': return _formatNumber(sph.totalJasa);
      case 'subtotal': return _formatNumber(sph.subtotal);
      case 'discount': return '${sph.discount}%';
      case 'ppn': return '${sph.ppn}%';
      case 'grand_total': return _formatNumber(sph.grandTotal);
      case 'terbilang': return _terbilang(sph.grandTotal);
      case 'sign_name': return null; // handled by settings
      case 'sign_position': return null; // handled by settings
      default: return null;
    }
  }

  static int? _parseRowFromAddress(String address) {
    final match = RegExp(r'(\d+)$').firstMatch(address);
    if (match != null) return int.tryParse(match.group(1)!);
    return null;
  }

  static void _insertTableRows(
    excel_lib.Sheet sheet,
    List<SphItem> items,
    List<CellMapping> tableMappings,
    List<CellMapping> headerMappings,
  ) {
    const totalFields = [
      'total_material', 'total_jasa', 'subtotal',
      'discount', 'ppn', 'grand_total', 'terbilang'
    ];

    final labelMapping = tableMappings.where((m) => m.fieldName == 'table_label').firstOrNull;
    if (labelMapping?.tableStartRow == null) return;
    final startRow = labelMapping!.tableStartRow!;

    int? firstTotalRow;
    for (final m in headerMappings) {
      if (totalFields.contains(m.fieldName) &&
          m.cellAddress != null && m.cellAddress!.isNotEmpty) {
        final row = _parseRowFromAddress(m.cellAddress!);
        if (row != null && (firstTotalRow == null || row < firstTotalRow)) {
          firstTotalRow = row;
        }
      }
    }
    if (firstTotalRow == null) return;

    final preAllocated = firstTotalRow - startRow;
    if (preAllocated <= 0) return;

    final itemsCount = items.length;
    if (itemsCount <= preAllocated) return;

    final extraRows = itemsCount - preAllocated;
    final insertIndex = firstTotalRow - 1;

    for (int i = 0; i < extraRows; i++) {
      sheet.insertRow(insertIndex);
    }

    for (int i = 0; i < headerMappings.length; i++) {
      final m = headerMappings[i];
      if (m.cellAddress != null && m.cellAddress!.isNotEmpty) {
        final row = _parseRowFromAddress(m.cellAddress!);
        if (row != null && row >= firstTotalRow) {
          final newAddress = m.cellAddress!.replaceAll(RegExp(r'\d+$'), (row + extraRows).toString());
          headerMappings[i] = m.copyWith(cellAddress: newAddress);
        }
      }
    }
  }

  static excel_lib.CellValue _toCellValue(num value) {
    if (value is int) return excel_lib.IntCellValue(value);
    return excel_lib.DoubleCellValue(value as double);
  }

  static void _writeCell(excel_lib.Sheet sheet, String address, String value) {
    if (address.isEmpty) return;
    final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));
    cell.value = excel_lib.TextCellValue(value);
  }

  static void _writeCellValue(excel_lib.Sheet sheet, String address, num value) {
    if (address.isEmpty) return;
    final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));
    if (value is int) {
      cell.value = excel_lib.IntCellValue(value);
    } else {
      cell.value = excel_lib.DoubleCellValue(value as double);
    }
  }

  static void _writeTableData(
    excel_lib.Sheet sheet, List<SphItem> items, List<CellMapping> tableMappings,
  ) {
    var sectionCount = 0;
    var itemCount = 0;
    var rowOffset = 0;

    final labelMapping = tableMappings.where((m) => m.fieldName == 'table_label').firstOrNull;
    final qtyMapping = tableMappings.where((m) => m.fieldName == 'table_qty').firstOrNull;
    final unitMapping = tableMappings.where((m) => m.fieldName == 'table_unit').firstOrNull;
    final priceMapping = tableMappings.where((m) => m.fieldName == 'table_unit_price').firstOrNull;
    final materialMapping = tableMappings.where((m) => m.fieldName == 'table_material').firstOrNull;
    final jasaMapping = tableMappings.where((m) => m.fieldName == 'table_jasa').firstOrNull;
    final amountMapping = tableMappings.where((m) => m.fieldName == 'table_amount').firstOrNull;

    final hasLabel = labelMapping != null && labelMapping.tableStartRow != null && labelMapping.tableColumn != null && labelMapping.tableColumn!.isNotEmpty;

    if (!hasLabel) return;

    final startRow = labelMapping!.tableStartRow!;

    for (final item in items) {
      final currentDataRow = startRow + rowOffset;
      if (item.type == 'section') {
        sectionCount++;
        itemCount = 0;
        final cellAddr = '${labelMapping.tableColumn}$currentDataRow';
        final sectionLabel = '${_roman(sectionCount)}. ${item.label}';
        _writeCell(sheet, cellAddr, sectionLabel);
      } else {
        itemCount++;
        final itemLabel = '${_letter(itemCount - 1)}. ${item.label}';

        _writeCell(sheet, '${labelMapping.tableColumn}$currentDataRow', itemLabel);

        if (qtyMapping?.tableStartRow != null && qtyMapping?.tableColumn != null && qtyMapping!.tableColumn!.isNotEmpty && item.qty > 0) {
          _writeCellValue(sheet, '${qtyMapping.tableColumn}$currentDataRow', item.qty);
        }
        if (unitMapping?.tableStartRow != null && unitMapping?.tableColumn != null && unitMapping!.tableColumn!.isNotEmpty && item.unit != null && item.unit!.isNotEmpty) {
          _writeCell(sheet, '${unitMapping.tableColumn}$currentDataRow', item.unit!);
        }
        if (priceMapping?.tableStartRow != null && priceMapping?.tableColumn != null && priceMapping!.tableColumn!.isNotEmpty) {
          _writeCellValue(sheet, '${priceMapping.tableColumn}$currentDataRow', item.unitPrice);
        }
        if (materialMapping?.tableStartRow != null && materialMapping?.tableColumn != null && materialMapping!.tableColumn!.isNotEmpty) {
          _writeCellValue(sheet, '${materialMapping.tableColumn}$currentDataRow', item.materialPrice * item.qty);
        }
        if (jasaMapping?.tableStartRow != null && jasaMapping?.tableColumn != null && jasaMapping!.tableColumn!.isNotEmpty) {
          _writeCellValue(sheet, '${jasaMapping.tableColumn}$currentDataRow', item.jasaPrice * item.qty);
        }
        if (amountMapping?.tableStartRow != null && amountMapping?.tableColumn != null && amountMapping!.tableColumn!.isNotEmpty) {
          _writeCellValue(sheet, '${amountMapping.tableColumn}$currentDataRow', item.totalPrice);
        }
      }
      rowOffset++;
    }
  }

  static void _writeTotals(
    excel_lib.Sheet sheet, Sph sph, List<CellMapping> headerMappings,
  ) {
    final totalMaterial = headerMappings.where((m) => m.fieldName == 'total_material').firstOrNull;
    final totalJasa = headerMappings.where((m) => m.fieldName == 'total_jasa').firstOrNull;
    final subtotal = headerMappings.where((m) => m.fieldName == 'subtotal').firstOrNull;
    final discount = headerMappings.where((m) => m.fieldName == 'discount').firstOrNull;
    final ppn = headerMappings.where((m) => m.fieldName == 'ppn').firstOrNull;
    final grandTotal = headerMappings.where((m) => m.fieldName == 'grand_total').firstOrNull;
    final terbilang = headerMappings.where((m) => m.fieldName == 'terbilang').firstOrNull;

    if (totalMaterial?.cellAddress?.isNotEmpty == true) _writeCellValue(sheet, totalMaterial!.cellAddress!, sph.totalMaterial);
    if (totalJasa?.cellAddress?.isNotEmpty == true) _writeCellValue(sheet, totalJasa!.cellAddress!, sph.totalJasa);
    if (subtotal?.cellAddress?.isNotEmpty == true) _writeCellValue(sheet, subtotal!.cellAddress!, sph.subtotal);
    if (discount?.cellAddress?.isNotEmpty == true) _writeCellValue(sheet, discount!.cellAddress!, sph.discount);
    if (ppn?.cellAddress?.isNotEmpty == true) _writeCellValue(sheet, ppn!.cellAddress!, sph.ppn);
    if (grandTotal?.cellAddress?.isNotEmpty == true) _writeCellValue(sheet, grandTotal!.cellAddress!, sph.grandTotal);
    if (terbilang?.cellAddress?.isNotEmpty == true) _writeCell(sheet, terbilang!.cellAddress!, _terbilang(sph.grandTotal));
  }

  static Future<void> _exportFromScratch(
    BuildContext context, Sph sph, List<SphItem> items,
  ) async {
    final excel = excel_lib.Excel.createExcel();
    final sheet = excel['SPH'];

    final headerStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 11,
      fontFamily: 'Calibri',
      horizontalAlign: excel_lib.HorizontalAlign.Center,
      backgroundColorHex: excel_lib.ExcelColor.fromHexString('FF4682B4'),
      fontColorHex: excel_lib.ExcelColor.fromHexString('FFFFFFFF'),
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );
    final dataStyle = excel_lib.CellStyle(
      fontSize: 10,
      fontFamily: 'Calibri',
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );
    final numStyle = excel_lib.CellStyle(
      fontSize: 10,
      fontFamily: 'Calibri',
      horizontalAlign: excel_lib.HorizontalAlign.Right,
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );
    final sectionStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 10,
      fontFamily: 'Calibri',
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );
    final totalStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 10,
      fontFamily: 'Calibri',
      horizontalAlign: excel_lib.HorizontalAlign.Right,
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Double),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );

    final headers = ['No', 'Uraian Pekerjaan', 'Qty', 'Sat', 'Harga Satuan', 'Material', 'Jasa', 'Jumlah'];
    final cols = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    for (int c = 0; c < headers.length; c++) {
      final cell = sheet.cell(excel_lib.CellIndex.indexByString('${cols[c]}1'));
      cell.value = excel_lib.TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    var sectionCount = 0;
    var itemCount = 0;
    for (int i = 0; i < items.length; i++) {
      final row = i + 2;
      final item = items[i];
      if (item.type == 'section') {
        sectionCount++;
        itemCount = 0;
        final cellA = sheet.cell(excel_lib.CellIndex.indexByString('A$row'));
        cellA.value = excel_lib.TextCellValue(_roman(sectionCount));
        cellA.cellStyle = sectionStyle;
        final cellB = sheet.cell(excel_lib.CellIndex.indexByString('B$row'));
        cellB.value = excel_lib.TextCellValue(item.label);
        cellB.cellStyle = sectionStyle;
        for (int c = 2; c < cols.length; c++) {
          sheet.cell(excel_lib.CellIndex.indexByString('${cols[c]}$row')).cellStyle = sectionStyle;
        }
      } else {
        itemCount++;
        final cellA = sheet.cell(excel_lib.CellIndex.indexByString('A$row'));
        cellA.value = excel_lib.TextCellValue(_letter(itemCount - 1));
        cellA.cellStyle = dataStyle;
        final cellB = sheet.cell(excel_lib.CellIndex.indexByString('B$row'));
        cellB.value = excel_lib.TextCellValue(item.label);
        cellB.cellStyle = dataStyle;
        final cellC = sheet.cell(excel_lib.CellIndex.indexByString('C$row'));
        cellC.value = excel_lib.IntCellValue(item.qty.toInt());
        cellC.cellStyle = numStyle;
        final cellD = sheet.cell(excel_lib.CellIndex.indexByString('D$row'));
        cellD.value = excel_lib.TextCellValue(item.unit ?? '');
        cellD.cellStyle = dataStyle;
        final cellE = sheet.cell(excel_lib.CellIndex.indexByString('E$row'));
        cellE.value = excel_lib.IntCellValue(item.unitPrice);
        cellE.cellStyle = numStyle;
        final cellF = sheet.cell(excel_lib.CellIndex.indexByString('F$row'));
        cellF.value = excel_lib.DoubleCellValue(item.materialPrice * item.qty);
        cellF.cellStyle = numStyle;
        final cellG = sheet.cell(excel_lib.CellIndex.indexByString('G$row'));
        cellG.value = excel_lib.DoubleCellValue(item.jasaPrice * item.qty);
        cellG.cellStyle = numStyle;
        final cellH = sheet.cell(excel_lib.CellIndex.indexByString('H$row'));
        cellH.value = excel_lib.IntCellValue(item.totalPrice);
        cellH.cellStyle = numStyle;
      }
    }

    final tr = items.length + 3;

    final totalLabelStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 10,
      fontFamily: 'Calibri',
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );

    final totalRows = [
      ('Total Material', sph.totalMaterial),
      ('Total Jasa', sph.totalJasa),
      ('Subtotal', sph.subtotal),
      ('Diskon', sph.discount),
      ('PPN', sph.ppn),
    ];
    for (int i = 0; i < totalRows.length; i++) {
      final r = tr + i;
      final cellB = sheet.cell(excel_lib.CellIndex.indexByString('B$r'));
      cellB.value = excel_lib.TextCellValue(totalRows[i].$1);
      cellB.cellStyle = totalLabelStyle;
      final cellH = sheet.cell(excel_lib.CellIndex.indexByString('H$r'));
      cellH.value = _toCellValue(totalRows[i].$2);
      cellH.cellStyle = totalStyle;
      for (int c = 1; c < 7; c++) {
        if (c == 1) continue;
        final col = cols[c];
        if (col == 'B' || col == 'H') continue;
        sheet.cell(excel_lib.CellIndex.indexByString('$col$r')).cellStyle = totalLabelStyle;
      }
    }

    final gr = tr + totalRows.length;
    final grandLabel = sheet.cell(excel_lib.CellIndex.indexByString('B$gr'));
    grandLabel.value = excel_lib.TextCellValue('Grand Total');
    grandLabel.cellStyle = totalLabelStyle;
    final grandCell = sheet.cell(excel_lib.CellIndex.indexByString('H$gr'));
    grandCell.value = _toCellValue(sph.grandTotal);
    grandCell.cellStyle = excel_lib.CellStyle(
      bold: true,
      fontSize: 11,
      fontFamily: 'Calibri',
      horizontalAlign: excel_lib.HorizontalAlign.Right,
      topBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Double),
      bottomBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Double),
      leftBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
      rightBorder: excel_lib.Border(borderStyle: excel_lib.BorderStyle.Thin),
    );

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${sph.number}.xlsx';
    final bytes = excel.save();
    if (bytes != null) {
      await File(filePath).writeAsBytes(bytes);
      await OpenFile.open(filePath);
    }
  }

  static Future<void> importTemplate(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null) return;

      final file = result.files.single;
      final bytes = file.bytes ?? (file.path != null ? File(file.path!).readAsBytesSync() : null);
      if (bytes == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membaca file')),
          );
        }
        return;
      }

      final excel = excel_lib.Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File Excel kosong')));
        }
        return;
      }

      final sheetName = excel.tables.keys.first;
      final sheet = excel[sheetName];
      final templateRepo = TemplateRepository();

      final templateId = await templateRepo.insert(SphTemplate(
        name: result.files.single.name.replaceAll('.xlsx', '').replaceAll('.xls', ''),
        description: 'Import dari Excel',
      ));

      int? currentSectionDbId;
      var sortOrder = 0;

      for (int row = 1; row < sheet.rows.length; row++) {
        final cells = sheet.rows[row];
        if (cells.isEmpty || cells[0]?.value == null) continue;

        final label = cells.length > 1 ? (cells[1]?.value?.toString() ?? '') : '';
        if (label.isEmpty) continue;

        final colA = cells[0]?.value?.toString().trim() ?? '';
        final qtyCell = cells.length > 2 ? cells[2]?.value?.toString() : '';

        final isSection = _isSectionRow(colA, label, qtyCell);

        if (isSection) {
          currentSectionDbId = await templateRepo.insertItem(TemplateItem(
            templateId: templateId,
            type: 'section',
            label: label,
            sortOrder: sortOrder++,
          ));
        } else {
          final unit = cells.length > 3 ? cells[3]?.value?.toString() ?? '' : '';

          await templateRepo.insertItem(TemplateItem(
            templateId: templateId,
            type: 'item',
            label: label,
            parentId: currentSectionDbId,
            sortOrder: sortOrder++,
            defaultUnit: unit,
          ));
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template berhasil diimport')));
      }
    } catch (e) {
      debugPrint('Import Excel Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal import Excel: $e')),
        );
      }
    }
  }

  static bool _isSectionRow(String colA, String label, String? qtyCell) {
    final romanPattern = RegExp(r'^\s*(I|II|III|IV|V|VI|VII|VIII|IX|X)\s*\.?\s*$');
    if (romanPattern.hasMatch(colA.trim())) return true;

    if (qtyCell == null || qtyCell.isEmpty) {
      if (label == label.toUpperCase() && label.length > 3) return true;
      if (label.length > 3 && !label.startsWith(RegExp(r'[a-z]\.'))) return true;
    }

    return false;
  }

  static String _roman(int n) {
    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const symbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
    var result = '';
    var num = n;
    for (var i = 0; i < values.length; i++) {
      while (num >= values[i]) {
        result += symbols[i];
        num -= values[i];
      }
    }
    return result;
  }

  static String _letter(int n) {
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    if (n < 26) return letters[n];
    return '${letters[n ~/ 26 - 1]}${letters[n % 26]}';
  }

  static String _formatNumber(int value) {
    final parts = value.toString().split('');
    final result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write('.');
      result.write(parts[i]);
    }
    return result.toString();
  }

  static String _terbilang(int number) {
    if (number == 0) return 'Nol Rupiah';
    final units = ['', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan'];
    final teens = ['sepuluh', 'sebelas', 'dua belas', 'tiga belas', 'empat belas', 'lima belas', 'enam belas', 'tujuh belas', 'delapan belas', 'sembilan belas'];
    final tens = ['', 'sepuluh', 'dua puluh', 'tiga puluh', 'empat puluh', 'lima puluh', 'enam puluh', 'tujuh puluh', 'delapan puluh', 'sembilan puluh'];
    final thousands = ['', 'ribu', 'juta', 'milyar', 'triliun'];

    String convertLessThan1000(int n) {
      String result = '';
      if (n >= 100) {
        if (n ~/ 100 == 1) result += 'seratus ';
        else result += '${units[n ~/ 100]} ratus ';
        n %= 100;
      }
      if (n >= 20) {
        result += '${tens[n ~/ 10]} ';
        n %= 10;
      } else if (n >= 10) {
        result += '${teens[n - 10]} ';
        n = 0;
      }
      if (n > 0) result += '${units[n]} ';
      return result;
    }

    String result = '';
    int num = number;
    int idx = 0;
    while (num > 0) {
      final seg = num % 1000;
      if (seg > 0) {
        if (idx == 1 && seg == 1) result = 'seribu $result';
        else result = '${convertLessThan1000(seg)}${thousands[idx]} $result';
      }
      num ~/= 1000;
      idx++;
    }
    return '${result.trim()} Rupiah';
  }
}
