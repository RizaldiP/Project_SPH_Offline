import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../models/template.dart';
class CellMappingScreen extends ConsumerStatefulWidget {
  const CellMappingScreen({super.key});

  @override
  ConsumerState<CellMappingScreen> createState() => _CellMappingScreenState();
}

class _CellMappingScreenState extends ConsumerState<CellMappingScreen> {
  List<CellMapping> _headerMappings = [];
  List<CellMapping> _tableMappings = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final Map<int, TextEditingController> _headerControllers = {};
  final Map<int, TextEditingController> _tableStartControllers = {};
  final Map<int, TextEditingController> _tableColumnControllers = {};
  final Map<int, TextEditingController> _tablePrototypeControllers = {};

  static const Map<String, String> _fieldLabels = {
    'sph_number': 'Nomor SPH',
    'sph_date': 'Tanggal SPH',
    'perihal': 'Perihal',
    'customer_name': 'Nama Customer',
    'customer_company': 'Perusahaan Customer',
    'customer_address': 'Alamat Customer',
    'ship_name': 'Nama Kapal',
    'validity_period': 'Masa Berlaku',
    'notes': 'Catatan',
    'total_material': 'Total Material',
    'total_jasa': 'Total Jasa',
    'subtotal': 'Subtotal',
    'discount': 'Diskon',
    'ppn': 'PPN',
    'grand_total': 'Grand Total',
    'terbilang': 'Terbilang',
    'sign_name': 'Nama Penanggung Jawab',
    'sign_position': 'Jabatan',
    'table_label': 'Kolom Uraian Pekerjaan',
    'table_qty': 'Kolom Jumlah (Qty)',
    'table_unit': 'Kolom Satuan',
    'table_unit_price': 'Kolom Harga Satuan',
    'table_material': 'Kolom Material',
    'table_jasa': 'Kolom Jasa',
    'table_amount': 'Kolom Jumlah (Total)',
  };

  @override
  void initState() {
    super.initState();
    _loadMappings();
  }

  Future<void> _loadMappings() async {
    final repo = ref.read(masterTemplateRepositoryProvider);
    final all = await repo.getAllMappings();
    final headers = <CellMapping>[];
    final tables = <CellMapping>[];
    for (final m in all) {
      if (m.isTableField == 1) {
        tables.add(m);
      } else {
        headers.add(m);
      }
    }
    for (final m in headers) {
      _headerControllers[m.id!] = TextEditingController(text: m.cellAddress ?? '');
    }
    for (final m in tables) {
      _tableStartControllers[m.id!] = TextEditingController(text: m.tableStartRow?.toString() ?? '');
      _tableColumnControllers[m.id!] = TextEditingController(text: m.tableColumn ?? '');
      _tablePrototypeControllers[m.id!] = TextEditingController(text: m.prototypeRow?.toString() ?? '');
    }
    if (mounted) {
      setState(() {
        _headerMappings = headers;
        _tableMappings = tables;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(masterTemplateRepositoryProvider);
      final updates = <CellMapping>[];

      for (final m in _headerMappings) {
        updates.add(m.copyWith(
          cellAddress: _headerControllers[m.id!]?.text.trim().toUpperCase(),
        ));
      }
      for (final m in _tableMappings) {
        updates.add(m.copyWith(
          tableStartRow: int.tryParse(_tableStartControllers[m.id!]?.text ?? ''),
          tableColumn: _tableColumnControllers[m.id!]?.text.trim().toUpperCase(),
          prototypeRow: int.tryParse(_tablePrototypeControllers[m.id!]?.text ?? ''),
        ));
      }

      await repo.updateMappings(updates);
      ref.invalidate(cellMappingsProvider);
      ref.invalidate(masterTemplateProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Posisi data berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    for (final c in _headerControllers.values) {
      c.dispose();
    }
    for (final c in _tableStartControllers.values) {
      c.dispose();
    }
    for (final c in _tableColumnControllers.values) {
      c.dispose();
    }
    for (final c in _tablePrototypeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Posisi Data'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Simpan',
              onPressed: _save,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('HEADER DOKUMEN', 'Isi alamat sel (contoh: B3, D5, F10)'),
                  const SizedBox(height: 8),
                  ..._headerMappings.map((m) => _buildHeaderField(m)),
                  const SizedBox(height: 24),
                  _buildSectionHeader('TABEL PEKERJAAN', 'Tentukan posisi awal tabel'),
                  const SizedBox(height: 8),
                  ..._tableMappings.map((m) => _buildTableField(m)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Pengaturan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpBox(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.darkGray)),
      ],
    );
  }

  Widget _buildHeaderField(CellMapping mapping) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              _fieldLabels[mapping.fieldName] ?? mapping.fieldName,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _headerControllers[mapping.id!],
              decoration: InputDecoration(
                hintText: 'contoh: B3',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableField(CellMapping mapping) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fieldLabels[mapping.fieldName] ?? mapping.fieldName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tableColumnControllers[mapping.id!],
                    decoration: const InputDecoration(
                      labelText: 'Kolom',
                      hintText: 'contoh: B',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _tableStartControllers[mapping.id!],
                    decoration: const InputDecoration(
                      labelText: 'Baris Mulai',
                      hintText: 'contoh: 6',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.navyBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.navyBlue.withValues(alpha: 0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Petunjuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(
            '1. Buka file template Anda di Microsoft Excel\n'
            '2. Catat alamat sel untuk setiap data (contoh: B3, D5)\n'
            '3. Untuk tabel, tentukan kolom (huruf) dan baris mulai\n'
            '4. Contoh: jika data pekerjaan dimulai dari baris 6 kolom B, isi Baris Mulai=6 dan Kolom=B',
            style: TextStyle(fontSize: 11, color: AppTheme.darkGray, height: 1.5),
          ),
        ],
      ),
    );
  }
}
