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
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            _buildHeader(settings),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text(
                'SURAT PENAWARAN HARGA (SPH)',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 16),
            _buildSphInfo(sph),
            pw.SizedBox(height: 16),
            _buildItemsTable(items),
            pw.SizedBox(height: 16),
            _buildTotals(sph),
            pw.SizedBox(height: 8),
            pw.Text(
              'Terbilang: ${NumberToWords.convert(sph.grandTotal.toInt())}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          settings.companyName ?? 'Perusahaan Saya',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        if (settings.address != null && settings.address!.isNotEmpty)
          pw.Text(settings.address!, style: pw.TextStyle(fontSize: 10)),
        if (settings.phone != null && settings.phone!.isNotEmpty)
          pw.Text('Telp: ${settings.phone}', style: pw.TextStyle(fontSize: 10)),
        if (settings.email != null && settings.email!.isNotEmpty)
          pw.Text('Email: ${settings.email}', style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildSphInfo(Sph sph) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text('Nomor: ${sph.number}', style: pw.TextStyle(fontSize: 11)),
            pw.Spacer(),
            pw.Text('Tanggal: ${sph.date ?? ""}', style: pw.TextStyle(fontSize: 11)),
          ],
        ),
        if (sph.title != null && sph.title!.isNotEmpty)
          pw.Text('Perihal: ${sph.title}', style: pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.Text('Kepada Yth,', style: pw.TextStyle(fontSize: 11)),
        pw.Text(sph.customerName ?? '-', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        if (sph.customerCompany != null && sph.customerCompany!.isNotEmpty)
          pw.Text(sph.customerCompany!, style: pw.TextStyle(fontSize: 11)),
        if (sph.customerAddress != null && sph.customerAddress!.isNotEmpty)
          pw.Text(sph.customerAddress!, style: pw.TextStyle(fontSize: 11)),
        pw.SizedBox(height: 8),
        if (sph.notes != null && sph.notes!.isNotEmpty)
          pw.Text('Catatan: ${sph.notes}', style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<SphItem> items) {
    if (items.isEmpty) {
      return pw.Text('Tidak ada item pekerjaan');
    }

    final headers = ['No', 'Uraian Pekerjaan', 'Qty', 'Sat', 'Harga Satuan', 'Material', 'Jasa', 'Jumlah'];

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: headers.map((h) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(4),
              color: PdfColors.grey300,
              child: pw.Text(h, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
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
            final label = isSection ? item.label : '${_pdfToLetter(itemCount - 1)}. ${item.label}';
            rows.add(pw.TableRow(
              children: [
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(number, style: pw.TextStyle(fontSize: 8))),
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    label,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: item.type == 'section' ? pw.FontWeight.bold : pw.FontWeight.normal,
                    ),
                  ),
                ),
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.type == 'item' ? '${item.qty}' : '', style: pw.TextStyle(fontSize: 8))),
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.unit ?? '', style: pw.TextStyle(fontSize: 8))),
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.type == 'item' ? Helpers.formatCurrency(item.unitPrice) : '', style: pw.TextStyle(fontSize: 8))),
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.type == 'item' ? Helpers.formatCurrency(item.materialPrice * item.qty) : '', style: pw.TextStyle(fontSize: 8))),
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.type == 'item' ? Helpers.formatCurrency(item.jasaPrice * item.qty) : '', style: pw.TextStyle(fontSize: 8))),
                pw.Container(padding: const pw.EdgeInsets.all(4), child: pw.Text(item.type == 'item' ? Helpers.formatCurrency(item.totalPrice) : '', style: pw.TextStyle(fontSize: 8))),
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
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Grand Total: ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(Helpers.formatCurrency(sph.grandTotal), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text('$label: ', style: pw.TextStyle(fontSize: 10)),
        pw.Text(value, style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildClosing(CompanySettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text('Demikian penawaran ini kami sampaikan.', style: pw.TextStyle(fontSize: 10)),
        pw.Text('Atas perhatian dan kerjasamanya, kami ucapkan terima kasih.', style: pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 24),
        pw.Text(settings.companyName ?? '', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 40),
        pw.Text('( ____________________ )', style: pw.TextStyle(fontSize: 10)),
        pw.Text('Direktur', style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }
}
