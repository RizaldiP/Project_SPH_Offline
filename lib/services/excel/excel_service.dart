import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../sph_repository.dart';
import '../template_repository.dart';
import '../../models/template.dart';

class ExcelService {
  static Future<void> export(BuildContext context, int sphId) async {
    try {
      final sphRepo = SphRepository();
      final sph = await sphRepo.getById(sphId);
      final items = await sphRepo.getItems(sphId);

      if (sph == null) return;

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

      for (int i = 0; i < items.length; i++) {
        final row = i + 2;
        final item = items[i];
        sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value = excel_lib.TextCellValue('${i + 1}');
        sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value = excel_lib.TextCellValue(item.label);
        sheet.cell(excel_lib.CellIndex.indexByString('C$row')).value = item.type == 'item' ? excel_lib.IntCellValue(item.qty.toInt()) : excel_lib.TextCellValue('');
        sheet.cell(excel_lib.CellIndex.indexByString('D$row')).value = excel_lib.TextCellValue(item.unit ?? '');
        sheet.cell(excel_lib.CellIndex.indexByString('E$row')).value = item.type == 'item' ? excel_lib.DoubleCellValue(item.unitPrice) : excel_lib.TextCellValue('');
        sheet.cell(excel_lib.CellIndex.indexByString('F$row')).value = item.type == 'item' ? excel_lib.DoubleCellValue(item.materialPrice * item.qty) : excel_lib.TextCellValue('');
        sheet.cell(excel_lib.CellIndex.indexByString('G$row')).value = item.type == 'item' ? excel_lib.DoubleCellValue(item.jasaPrice * item.qty) : excel_lib.TextCellValue('');
        sheet.cell(excel_lib.CellIndex.indexByString('H$row')).value = item.type == 'item' ? excel_lib.DoubleCellValue(item.totalPrice) : excel_lib.TextCellValue('');
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
    } catch (e) {
      debugPrint('Excel Export Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export Excel: $e')),
        );
      }
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

      for (int row = 1; row < sheet.rows.length; row++) {
        final cells = sheet.rows[row];
        if (cells.isNotEmpty && cells[0]?.value != null) {
          final label = cells.length > 1 ? (cells[1]?.value?.toString() ?? '') : '';
          if (label.isNotEmpty) {
            await templateRepo.insertItem(TemplateItem(
              templateId: templateId,
              type: 'item',
              label: label,
              sortOrder: row - 1,
            ));
          }
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
}
