# Changelog

Semua perubahan signifikan pada project **SPH Generator Mobile Offline** akan dicatat di sini.

Format mengacu pada [Keep a Changelog](https://keepachangelog.com/) dan versi mengikuti [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2026-06-26

### Added
- **Dashboard** — Menu utama dengan navigasi cepat: Buat SPH Baru, Draft, Riwayat, Customer, Template, Material, Pengaturan.
- **SPH CRUD** — Buat, edit, duplikat, dan hapus dokumen Surat Penawaran Harga.
- **SPH Form** — Form multi-section (I, II, III...) dan item (a, b, c...) dengan collapse/expand dan drag-and-drop reorder.
- **Item Editor** — Modal dialog untuk edit qty, unit, material price, jasa price, dan auto/manual pricing mode.
- **Auto-kalkulasi** — Total material, total jasa, subtotal, diskon (%), PPN (%), grand total dihitung otomatis.
- **Master Customer** — Tambah, edit, hapus, dan cari data pelanggan.
- **Master Material** — Tambah, edit, hapus, dan cari data material dengan standar harga. Auto-populate dari item SPH.
- **Work Template** — Buat template pekerjaan reusable. Auto-save dari section SPH yang memiliki jasa. Import dari Excel.
- **History & Filter** — Rihat SPH dengan filter status (draft/selesai) dan pencarian.
- **PDF Export** — Generate PDF A4 profesional dengan kop surat, logo, tabel item, total, terbilang, dan tanda tangan.
- **Excel Export** — Export ke Excel dengan dua mode:
  - *Template-driven*: menggunakan template Excel perusahaan + cell mapping.
  - *From-scratch*: jika belum ada template.
- **Excel Import** — Import file Excel untuk membuat work template.
- **Master Template Excel** — Upload template Excel perusahaan dan konfigurasi mapping cell ke field SPH.
- **Settings** — Pengaturan perusahaan: nama, alamat, telepon, email, website, NPWP, logo, signature, stempel, default PPN, catatan kaki.
- **Number to Words** — Konversi angka ke teks bahasa Indonesia (terbilang) untuk PDF.
- **Database SQLite** — 9 tabel dengan relasi foreign key, migration v1→v2.
- **Riverpod State Management** — Provider pattern dengan FutureProvider, StateNotifierProvider, dan auto-invalidation.

### Database
- Tabel `settings`, `customers`, `materials`, `sph`, `sph_items`, `sph_templates`, `sph_template_items`, `master_template`, `cell_mapping`.
- Migration v1 → v2: tambah kolom `signature_name`, `signature_position`, `notes` di `settings`; tambah tabel `master_template` dan `cell_mapping`.
- Default data: settings awal, default cell mappings (17 header + 7 table fields).

### Technical
- Flutter 3.x dengan Dart SDK ^3.12.1.
- 100% offline — tanpa koneksi internet.
- Feature-first folder structure.
- Singleton database helper.
- Immutable models dengan `copyWith()`.
- Template-driven document generation untuk Excel.
