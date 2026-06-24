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

      if (template != null && await templateRepo.isMappingComplete()) {
        await _exportWithTemplate(context, sph, items, template, templateRepo);
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
      case 'terbilang': return _terbilang(sph.grandTotal.toInt());
      default: return null;
    }
  }

  static void _writeCell(excel_lib.Sheet sheet, String address, String value) {
    final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));
    cell.value = excel_lib.TextCellValue(value);
  }

  static void _writeNumberCell(excel_lib.Sheet sheet, String address, double value) {
    final cell = sheet.cell(excel_lib.CellIndex.indexByString(address));
    cell.value = excel_lib.DoubleCellValue(value);
  }

  static void _writeTableData(
    excel_lib.Sheet sheet, List<SphItem> items, List<CellMapping> tableMappings,
  ) {
    var sectionCount = 0;
    var itemCount = 0;
    var currentDataRow = 0;

    final labelMapping = tableMappings.where((m) => m.fieldName == 'table_label').firstOrNull;
    final qtyMapping = tableMappings.where((m) => m.fieldName == 'table_qty').firstOrNull;
    final unitMapping = tableMappings.where((m) => m.fieldName == 'table_unit').firstOrNull;
    final priceMapping = tableMappings.where((m) => m.fieldName == 'table_unit_price').firstOrNull;
    final materialMapping = tableMappings.where((m) => m.fieldName == 'table_material').firstOrNull;
    final jasaMapping = tableMappings.where((m) => m.fieldName == 'table_jasa').firstOrNull;
    final amountMapping = tableMappings.where((m) => m.fieldName == 'table_amount').firstOrNull;

    for (final item in items) {
      if (item.type == 'section') {
        sectionCount++;
        itemCount = 0;
        currentDataRow = (labelMapping?.tableStartRow ?? 6) + (items.indexOf(item));
        final cellAddr = '${labelMapping?.tableColumn ?? 'B'}$currentDataRow';
        final sectionLabel = '${_roman(sectionCount)}. ${item.label}';
        _writeCell(sheet, cellAddr, sectionLabel);
      } else {
        itemCount++;
        currentDataRow = (labelMapping?.tableStartRow ?? 6) + (items.indexOf(item));
        final itemLabel = '${_letter(itemCount - 1)}. ${item.label}';
        final labelCol = labelMapping?.tableColumn ?? 'B';
        final qtyCol = qtyMapping?.tableColumn ?? 'C';
        final unitCol = unitMapping?.tableColumn ?? 'D';
        final priceCol = priceMapping?.tableColumn ?? 'E';
        final materialCol = materialMapping?.tableColumn ?? 'F';
        final jasaCol = jasaMapping?.tableColumn ?? 'G';
        final amountCol = amountMapping?.tableColumn ?? 'H';

        _writeCell(sheet, '$labelCol$currentDataRow', itemLabel);
        if (item.qty > 0) {
          _writeNumberCell(sheet, '$qtyCol$currentDataRow', item.qty);
        }
        if (item.unit != null && item.unit!.isNotEmpty) {
          _writeCell(sheet, '$unitCol$currentDataRow', item.unit!);
        }
        _writeNumberCell(sheet, '$priceCol$currentDataRow', item.unitPrice);
        _writeNumberCell(sheet, '$materialCol$currentDataRow', item.materialPrice * item.qty);
        _writeNumberCell(sheet, '$jasaCol$currentDataRow', item.jasaPrice * item.qty);
        _writeNumberCell(sheet, '$amountCol$currentDataRow', item.totalPrice);
      }
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

    if (totalMaterial?.cellAddress != null) _writeCell(sheet, totalMaterial!.cellAddress!, _formatNumber(sph.totalMaterial));
    if (totalJasa?.cellAddress != null) _writeCell(sheet, totalJasa!.cellAddress!, _formatNumber(sph.totalJasa));
    if (subtotal?.cellAddress != null) _writeCell(sheet, subtotal!.cellAddress!, _formatNumber(sph.subtotal));
    if (discount?.cellAddress != null) _writeCell(sheet, discount!.cellAddress!, '${sph.discount}%');
    if (ppn?.cellAddress != null) _writeCell(sheet, ppn!.cellAddress!, '${sph.ppn}%');
    if (grandTotal?.cellAddress != null) _writeCell(sheet, grandTotal!.cellAddress!, _formatNumber(sph.grandTotal));
    if (terbilang?.cellAddress != null) _writeCell(sheet, terbilang!.cellAddress!, _terbilang(sph.grandTotal.toInt()));
  }

  static Future<void> _exportFromScratch(
    BuildContext context, Sph sph, List<SphItem> items,
  ) async {
    final excel = excel_lib.Excel.createExcel();
    final sheet = excel['SPH'];

    sheet.cell(excel_lib.CellIndex.indexByString('A1')).value = excel_lib.TextCellValue('No');
    sheet.cell(excel_lib.CellIndex.indexByString('B1')).value = excel_lib.TextCellValue('Uraian Pekerjaan');
    sheet.cell(excel_lib.CellIndex.indexByString('C1')).value = excel_lib.TextCellValue('Qty');
    sheet.cell(excel_lib.CellIndex.indexByString('D1')).value = excel_lib.TextCellValue('Sat');
    sheet.cell(excel_lib.CellIndex.indexByString('E1')).value = excel_lib.TextCellValue('Harga Satuan');
    sheet.cell(excel_lib.CellIndex.indexByString('F1')).value = excel_lib.TextCellValue('Material');
    sheet.cell(excel_lib.CellIndex.indexByString('G1')).value = excel_lib.TextCellValue('Jasa');
    sheet.cell(excel_lib.CellIndex.indexByString('H1')).value = excel_lib.TextCellValue('Jumlah');

    var sectionCount = 0;
    var itemCount = 0;
    for (int i = 0; i < items.length; i++) {
      final row = i + 2;
      final item = items[i];
      if (item.type == 'section') {
        sectionCount++;
        itemCount = 0;
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value = excel_lib.TextCellValue(_roman(sectionCount));
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value = excel_lib.TextCellValue(item.label);
      } else {
        itemCount++;
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value = excel_lib.TextCellValue(_letter(itemCount - 1));
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value = excel_lib.TextCellValue(item.label);
        sheet.cell(excel_lib.CellIndex.indexByString('C$row')).value = excel_lib.IntCellValue(item.qty.toInt());
        sheet.cell(excel_lib.CellIndex.indexByString('D$row')).value = excel_lib.TextCellValue(item.unit ?? '');
        sheet.cell(excel_lib.CellIndex.indexByString('E$row')).value = excel_lib.DoubleCellValue(item.unitPrice);
        sheet.cell(excel_lib.CellIndex.indexByString('F$row')).value = excel_lib.DoubleCellValue(item.materialPrice * item.qty);
        sheet.cell(excel_lib.CellIndex.indexByString('G$row')).value = excel_lib.DoubleCellValue(item.jasaPrice * item.qty);
        sheet.cell(excel_lib.CellIndex.indexByString('H$row')).value = excel_lib.DoubleCellValue(item.totalPrice);
      }
    }

    final tr = items.length + 3;
    sheet.cell(excel_lib.CellIndex.indexByString('B$tr')).value = excel_lib.TextCellValue('Total Material');
    sheet.cell(excel_lib.CellIndex.indexByString('H$tr')).value = excel_lib.DoubleCellValue(sph.totalMaterial);
    sheet.cell(excel_lib.CellIndex.indexByString('B${tr + 1}')).value = excel_lib.TextCellValue('Total Jasa');
    sheet.cell(excel_lib.CellIndex.indexByString('H${tr + 1}')).value = excel_lib.DoubleCellValue(sph.totalJasa);
    sheet.cell(excel_lib.CellIndex.indexByString('B${tr + 2}')).value = excel_lib.TextCellValue('Subtotal');
    sheet.cell(excel_lib.CellIndex.indexByString('H${tr + 2}')).value = excel_lib.DoubleCellValue(sph.subtotal);
    sheet.cell(excel_lib.CellIndex.indexByString('B${tr + 3}')).value = excel_lib.TextCellValue('Diskon');
    sheet.cell(excel_lib.CellIndex.indexByString('H${tr + 3}')).value = excel_lib.DoubleCellValue(sph.discount);
    sheet.cell(excel_lib.CellIndex.indexByString('B${tr + 4}')).value = excel_lib.TextCellValue('PPN');
    sheet.cell(excel_lib.CellIndex.indexByString('H${tr + 4}')).value = excel_lib.DoubleCellValue(sph.ppn);
    sheet.cell(excel_lib.CellIndex.indexByString('B${tr + 5}')).value = excel_lib.TextCellValue('Grand Total');
    sheet.cell(excel_lib.CellIndex.indexByString('H${tr + 5}')).value = excel_lib.DoubleCellValue(sph.grandTotal);

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
      if (result == null || result.files.single.path == null) return;

      final bytes = File(result.files.single.path!).readAsBytesSync();
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

  static String _formatNumber(double value) {
    final parts = value.toStringAsFixed(0).split('');
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
