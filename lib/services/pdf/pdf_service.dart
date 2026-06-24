import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../sph_repository.dart';
import '../settings_repository.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/number_to_words.dart';
import '../../models/sph.dart';
import '../../models/sph_item.dart';
import '../../models/company_settings.dart';

String _pdfToRoman(int n) {
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

String _pdfToLetter(int n) {
  const letters = 'abcdefghijklmnopqrstuvwxyz';
  if (n < 26) return letters[n];
  return '${letters[n ~/ 26 - 1]}${letters[n % 26]}';
}

class PdfService {
  static Future<void> export(BuildContext context, int sphId) async {
    try {
      final sphRepo = SphRepository();
      final settingsRepo = SettingsRepository();
      final sph = await sphRepo.getById(sphId);
      final items = await sphRepo.getItems(sphId);
      final settings = await settingsRepo.get();

      if (sph == null) return;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            _buildHeader(settings),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(
                'SURAT PENAWARAN HARGA (SPH)',
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 12),
            _buildSphInfo(sph),
            pw.SizedBox(height: 12),
            _buildItemsTable(items),
            pw.SizedBox(height: 16),
            _buildTotals(sph),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
              ),
              child: pw.Text(
                'Terbilang: ${NumberToWords.convert(sph.grandTotal.toInt())}',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 24),
            _buildClosing(settings),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${sph.number}.pdf',
      );
    } catch (e) {
      debugPrint('PDF Error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export PDF: $e')),
        );
      }
    }
  }

  static pw.Widget _buildHeader(CompanySettings settings) {
    final headerChildren = <pw.Widget>[];

    if (settings.logoPath != null && settings.logoPath!.isNotEmpty) {
      final logoFile = File(settings.logoPath!);
      if (logoFile.existsSync()) {
        headerChildren.add(
          pw.Container(
            width: 80,
            height: 80,
            child: pw.Image(pw.MemoryImage(logoFile.readAsBytesSync())),
          ),
        );
        headerChildren.add(pw.SizedBox(height: 8));
      }
    }

    headerChildren.addAll([
      pw.Text(
        settings.companyName ?? 'Perusahaan Saya',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
      ),
      if (settings.address != null && settings.address!.isNotEmpty)
        pw.Text(settings.address!, style: pw.TextStyle(fontSize: 9)),
      if (settings.phone != null && settings.phone!.isNotEmpty)
        pw.Text('Telp: ${settings.phone}', style: pw.TextStyle(fontSize: 9)),
      if (settings.email != null && settings.email!.isNotEmpty)
        pw.Text('Email: ${settings.email}', style: pw.TextStyle(fontSize: 9)),
      if (settings.website != null && settings.website!.isNotEmpty)
        pw.Text('Website: ${settings.website}', style: pw.TextStyle(fontSize: 9)),
      if (settings.npwp != null && settings.npwp!.isNotEmpty)
        pw.Text('NPWP: ${settings.npwp}', style: pw.TextStyle(fontSize: 9)),
    ]);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: headerChildren,
    );
  }

  static pw.Widget _buildSphInfo(Sph sph) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text('Nomor: ${sph.number}', style: pw.TextStyle(fontSize: 10)),
              pw.Spacer(),
              pw.Text('Tanggal: ${sph.date ?? ""}', style: pw.TextStyle(fontSize: 10)),
            ],
          ),
          if (sph.title != null && sph.title!.isNotEmpty)
            pw.Text('Perihal: ${sph.title}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text('Kepada Yth,', style: pw.TextStyle(fontSize: 10)),
          pw.Text(sph.customerName ?? '-', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          if (sph.customerCompany != null && sph.customerCompany!.isNotEmpty)
            pw.Text(sph.customerCompany!, style: pw.TextStyle(fontSize: 10)),
          if (sph.customerAddress != null && sph.customerAddress!.isNotEmpty)
            pw.Text(sph.customerAddress!, style: pw.TextStyle(fontSize: 10)),
          if (sph.shipName != null && sph.shipName!.isNotEmpty)
            pw.Text('Nama Kapal: ${sph.shipName}', style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<SphItem> items) {
    if (items.isEmpty) {
      return pw.Text('Tidak ada item pekerjaan');
    }

    final headers = ['No', 'Uraian Pekerjaan', 'Qty', 'Sat', 'Harga Satuan', 'Material', 'Jasa', 'Jumlah'];
    final colWidths = <double>[20, 220, 30, 25, 55, 55, 55, 55];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        for (int i = 0; i < colWidths.length; i++) i: pw.FixedColumnWidth(colWidths[i]),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: headers.map((h) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(3),
              child: pw.Text(h, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
            );
          }).toList(),
        ),
        ...() {
          final rows = <pw.TableRow>[];
          var sectionCount = 0;
          var itemCount = 0;
          for (final item in items) {
            if (item.type == 'section') {
              sectionCount++;
              itemCount = 0;
            } else {
              itemCount++;
            }
            final isSection = item.type == 'section';
            final number = isSection ? _pdfToRoman(sectionCount) : '';
            final label = isSection
                ? '${_pdfToRoman(sectionCount)}. ${item.label}'
                : '${_pdfToLetter(itemCount - 1)}. ${item.label}';
            rows.add(pw.TableRow(
              children: [
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(number, style: pw.TextStyle(fontSize: 7))),
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  child: pw.Text(
                    label,
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: isSection ? pw.FontWeight.bold : pw.FontWeight.normal,
                    ),
                  ),
                ),
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(
                  item.type == 'item' ? '${item.qty}' : '',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.right,
                )),
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(item.unit ?? '', style: pw.TextStyle(fontSize: 7))),
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(
                  item.type == 'item' ? Helpers.formatCurrency(item.unitPrice) : '',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.right,
                )),
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(
                  item.type == 'item' ? Helpers.formatCurrency(item.materialPrice * item.qty) : '',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.right,
                )),
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(
                  item.type == 'item' ? Helpers.formatCurrency(item.jasaPrice * item.qty) : '',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.right,
                )),
                pw.Container(padding: const pw.EdgeInsets.all(3), child: pw.Text(
                  item.type == 'item' ? Helpers.formatCurrency(item.totalPrice) : '',
                  style: pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.right,
                )),
              ],
            ));
          }
          return rows;
        }(),
      ],
    );
  }

  static pw.Widget _buildTotals(Sph sph) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _totalRow('Total Material', Helpers.formatCurrency(sph.totalMaterial)),
        _totalRow('Total Jasa', Helpers.formatCurrency(sph.totalJasa)),
        _totalRow('Subtotal', Helpers.formatCurrency(sph.subtotal)),
        _totalRow('Diskon', '${sph.discount}%'),
        _totalRow('PPN', '${sph.ppn}%'),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey600),
            color: PdfColors.grey100,
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Grand Total: ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(Helpers.formatCurrency(sph.grandTotal), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontSize: 9)),
          pw.Text(value, style: pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildClosing(CompanySettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (settings.notes != null && settings.notes!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 16),
            child: pw.Text(settings.notes!, style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic)),
          ),
        pw.Text('Demikian penawaran ini kami sampaikan.', style: pw.TextStyle(fontSize: 9)),
        pw.Text('Atas perhatian dan kerjasamanya, kami ucapkan terima kasih.', style: pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 24),
        pw.Text(settings.companyName ?? '', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 40),
        pw.Text('( ${settings.signatureName ?? "____________________"} )', style: pw.TextStyle(fontSize: 10)),
        pw.Text(settings.signaturePosition ?? 'Direktur', style: pw.TextStyle(fontSize: 9)),
      ],
    );
  }
}
