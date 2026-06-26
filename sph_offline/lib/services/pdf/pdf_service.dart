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

const _steelBlue = PdfColor(0.282, 0.510, 0.706);
const _lightBlue = PdfColor(0.90, 0.937, 0.965);
const _steelBlueLight = PdfColor(0.65, 0.75, 0.85);

String _roman(int n) {
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

String _letter(int n) {
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
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            _buildHeader(settings),
            pw.SizedBox(height: 10),
            _buildTitle(),
            pw.SizedBox(height: 8),
            _buildSphInfo(sph),
            pw.SizedBox(height: 12),
            _buildItemsTable(items, sph),
            pw.SizedBox(height: 8),
            _buildTerbilang(sph),
            pw.SizedBox(height: 20),
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
            width: 70,
            height: 70,
            child: pw.Image(pw.MemoryImage(logoFile.readAsBytesSync())),
          ),
        );
        headerChildren.add(pw.SizedBox(height: 6));
      }
    }

    headerChildren.addAll([
      pw.Text(
        settings.companyName ?? 'Perusahaan Saya',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      if (settings.address != null && settings.address!.isNotEmpty)
        pw.Text(settings.address!, style: const pw.TextStyle(fontSize: 9)),
      if (settings.phone != null && settings.phone!.isNotEmpty)
        pw.Text('Telp: ${settings.phone} | Email: ${settings.email ?? "-"}',
            style: const pw.TextStyle(fontSize: 9)),
      if (settings.website != null && settings.website!.isNotEmpty)
        pw.Text('Website: ${settings.website}',
            style: const pw.TextStyle(fontSize: 9)),
      if (settings.npwp != null && settings.npwp!.isNotEmpty)
        pw.Text('NPWP: ${settings.npwp}', style: const pw.TextStyle(fontSize: 9)),
    ]);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: headerChildren,
    );
  }

  static pw.Widget _buildTitle() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _steelBlue, width: 2),
          bottom: pw.BorderSide(color: _steelBlue, width: 2),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'SURAT PENAWARAN HARGA (SPH)',
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: _steelBlue,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildSphInfo(Sph sph) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _lightBlue,
        border: pw.Border.all(color: _steelBlueLight),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text('Nomor: ${sph.number}',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Spacer(),
              pw.Text('Tanggal: ${sph.date ?? ""}',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Kepada Yth.',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(sph.customerName ?? '-',
                        style: const pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    if (sph.customerCompany != null &&
                        sph.customerCompany!.isNotEmpty)
                      pw.Text(sph.customerCompany!,
                          style: const pw.TextStyle(fontSize: 10)),
                    if (sph.customerAddress != null &&
                        sph.customerAddress!.isNotEmpty)
                      pw.Text(sph.customerAddress!,
                          style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          if (sph.title != null && sph.title!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _steelBlueLight),
              ),
              child: pw.Text(
                '${sph.title}${sph.shipName != null && sph.shipName!.isNotEmpty ? ' ${sph.shipName}' : ''}',
                style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
          if (sph.validityPeriod != null && sph.validityPeriod!.isNotEmpty)
            pw.Text('Masa Berlaku: ${sph.validityPeriod}',
                style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<SphItem> items, Sph sph) {
    if (items.isEmpty) {
      return pw.Text('Tidak ada item pekerjaan');
    }

    const headers = [
      'No',
      'Uraian Pekerjaan',
      'Qty',
      'Sat',
      'Harga Satuan',
      'Material',
      'Jasa',
      'Jumlah'
    ];

    final colWidths = const {
      0: pw.FixedColumnWidth(22),
      1: pw.FlexColumnWidth(),
      2: pw.FixedColumnWidth(26),
      3: pw.FixedColumnWidth(24),
      4: pw.FixedColumnWidth(60),
      5: pw.FixedColumnWidth(60),
      6: pw.FixedColumnWidth(60),
      7: pw.FixedColumnWidth(60),
    };

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.5,
      ),
      columnWidths: colWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _steelBlue),
          children: headers.map((h) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                h,
                style: const pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
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
            final number =
                isSection ? _roman(sectionCount) : _letter(itemCount - 1);
            final label = isSection
                ? item.label
                : '${_letter(itemCount - 1)}. ${item.label}';

            rows.add(pw.TableRow(
              decoration: isSection
                  ? pw.BoxDecoration(color: _lightBlue)
                  : null,
              children: [
                _cell(isSection ? number : '',
                    isSection: isSection),
                _cell(label,
                    isSection: isSection,
                    fontWeight:
                        isSection ? pw.FontWeight.bold : pw.FontWeight.normal),
                _cell(
                    item.type == 'item' ? '${item.qty.toInt()}' : '',
                    align: pw.TextAlign.right),
                _cell(item.unit ?? ''),
                _cell(
                    item.type == 'item'
                        ? Helpers.formatCurrency(item.unitPrice)
                        : '',
                    align: pw.TextAlign.right),
                _cell(
                    item.type == 'item'
                        ? Helpers.formatCurrency(
                            (item.materialPrice * item.qty).toInt())
                        : '',
                    align: pw.TextAlign.right),
                _cell(
                    item.type == 'item'
                        ? Helpers.formatCurrency(
                            (item.jasaPrice * item.qty).toInt())
                        : '',
                    align: pw.TextAlign.right),
                _cell(
                    item.type == 'item'
                        ? Helpers.formatCurrency(item.totalPrice)
                        : '',
                    align: pw.TextAlign.right,
                    fontWeight: pw.FontWeight.bold),
              ],
            ));
          }
          return rows;
        }(),
        ..._buildSummaryRows(sph),
      ],
    );
  }

  static List<pw.TableRow> _buildSummaryRows(Sph sph) {
    final subtotal = sph.totalMaterial + sph.totalJasa;
    final ppnAmount = ((11 / 12 * subtotal) * 12 / 100).round();
    final grandTotal = subtotal + ppnAmount;

    return [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _lightBlue),
        children: [
          pw.TableCell(
            columnSpan: 5,
            child: _boldCell('Sub Total'),
          ),
          _boldRightCell(Helpers.formatCurrency(sph.totalMaterial)),
          _boldRightCell(Helpers.formatCurrency(sph.totalJasa)),
          _boldRightCell(Helpers.formatCurrency(subtotal)),
        ],
      ),
      pw.TableRow(
        children: [
          pw.TableCell(
            columnSpan: 7,
            child: _boldCell('PPN'),
          ),
          _boldRightCell(Helpers.formatCurrency(ppnAmount)),
        ],
      ),
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _lightBlue),
        children: [
          pw.TableCell(
            columnSpan: 7,
            child: _boldCell('Total'),
          ),
          _boldRightCell(Helpers.formatCurrency(grandTotal)),
        ],
      ),
    ];
  }

  static pw.Widget _boldCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(text,
          style: const pw.TextStyle(
              fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _boldRightCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(text,
          style: const pw.TextStyle(
              fontSize: 7.5, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.right),
    );
  }

  static pw.Widget _cell(String text,
      {pw.TextAlign align = pw.TextAlign.left,
      bool isSection = false,
      pw.FontWeight fontWeight = pw.FontWeight.normal}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: fontWeight,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTerbilang(Sph sph) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Text(
        'Terbilang: ${NumberToWords.convert(sph.grandTotal)}',
        style: const pw.TextStyle(
            fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildClosing(CompanySettings settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        if (settings.notes != null && settings.notes!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              settings.notes!,
              style: const pw.TextStyle(
                  fontSize: 9, fontStyle: pw.FontStyle.italic),
            ),
          ),
        pw.SizedBox(height: 16),
        pw.Text(
          settings.companyName ?? '',
          style: const pw.TextStyle(
              fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 36),
        pw.Container(
          width: 200,
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey400),
            ),
          ),
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Center(
            child: pw.Text(
              settings.signatureName ?? '____________________',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ),
        pw.Text(
          settings.signaturePosition ?? 'Direktur',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}
