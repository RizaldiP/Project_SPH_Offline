SPH GENERATOR MOBILE OFFLINE

Engineering Quotation & Cost Estimation System

---

PROJECT OVERVIEW

Buat aplikasi Android menggunakan Flutter yang berfungsi untuk membuat Surat Penawaran Harga (SPH), RAB, Quotation, dan Cost Estimation secara cepat langsung dari HP tanpa menggunakan Excel atau laptop.

Aplikasi harus:

- Offline 100%
- Ringan
- Cepat
- Mudah digunakan
- Tampilan profesional
- Cocok untuk bidang Marine, Electrical, Mechanical, Maintenance, Kontraktor, dan Engineering

Target utama adalah menggantikan proses pembuatan SPH menggunakan Microsoft Excel.

---

TECHNOLOGY STACK

Framework

Flutter

Database

SQLite

State Management

Riverpod

Export Engine

- PDF Generator
- Excel Generator (.xlsx)

---

MAIN FEATURES

Dashboard

Menu utama:

- Buat SPH Baru
- Draft SPH
- Riwayat SPH
- Master Customer
- Master Template
- Master Material
- Pengaturan

---

HEADER SPH

Field yang harus tersedia:

Nomor SPH

Tanggal

Perihal

Nama Customer

Nama Perusahaan Customer

Nama Kapal (Opsional)

Alamat

PIC Customer

Masa Berlaku Penawaran

Catatan Tambahan

---

DATA PERUSAHAAN

Data disimpan permanen.

Nama Perusahaan

Alamat

Telepon

Email

Website

Logo

Tanda Tangan Digital

Stempel Digital

NPWP (Opsional)

---

FORMAT TABEL SPH

Format harus mengikuti SPH Engineering.

| No | Uraian Pekerjaan | Jml | Sat | Harga Satuan | Material | Jasa | Jumlah |

---

STRUKTUR DATA PEKERJAAN

Sistem harus mendukung struktur bertingkat.

Contoh:

I. Perbaikan Alternator

a. Pembongkaran unit alternator

b. Pembersihan komponen

c. Pemeriksaan rotor

d. Perakitan kembali

II. Penggantian Kabel

a. Pengadaan kabel

b. Instalasi kabel

c. Pengujian kabel

III. Material Yang Dibutuhkan

a. Kabel NYAF

b. Terminal Lug

c. Relay

---

TIPE BARIS

SECTION

Contoh:

I. Perbaikan Alternator

II. Penggantian Kabel

III. Material Yang Dibutuhkan

Karakteristik:

- Tidak dihitung
- Tidak memiliki qty
- Tidak memiliki harga
- Hanya sebagai grup pekerjaan

Nomor otomatis:

I

II

III

IV

V

dst

---

ITEM PEKERJAAN

Contoh:

a. Pembongkaran unit alternator

b. Pembersihan komponen

c. Pemeriksaan rotor

d. Perakitan kembali

Karakteristik:

Dapat memiliki:

Qty

Satuan

Harga Satuan

Material

Jasa

Jumlah

Penomoran otomatis:

a

b

c

d

e

dst

---

PERHITUNGAN

Mode Otomatis

Input:

Material

Jasa

Sistem menghitung:

Harga Satuan = Material + Jasa

Jumlah = Qty × Harga Satuan

---

Mode Manual

Input:

Harga Satuan

Jumlah

Sistem menghitung:

Jumlah = Qty × Harga Satuan

---

Fleksibel

Harus mendukung:

- Hanya Material
- Hanya Jasa
- Material + Jasa
- Harga Manual

Karena format SPH setiap perusahaan berbeda.

---

REKAP TOTAL

Di bawah tabel otomatis muncul:

Total Material

Total Jasa

Subtotal

Diskon

PPN (%)

Grand Total

---

TERBILANG

Contoh:

Rp 23.750.000

Menjadi:

Dua Puluh Tiga Juta Tujuh Ratus Lima Puluh Ribu Rupiah

Terbilang otomatis mengikuti Grand Total.

---

MASTER CUSTOMER

Data:

Nama Customer

Nama Perusahaan

Alamat

Telepon

Email

PIC

Catatan

Saat membuat SPH cukup memilih customer.

---

MASTER MATERIAL

Data:

Nama Material

Kategori

Satuan

Harga Standar

Supplier

Catatan

Contoh:

Kabel NYAF

Relay

MCB

Terminal Lug

Bearing

Kontaktor

Push Button

---

MASTER TEMPLATE PEKERJAAN

Fitur sangat penting.

User dapat membuat template pekerjaan.

Contoh:

Template:

Perbaikan Alternator

Isi:

a. Pembongkaran unit

b. Pembersihan komponen

c. Pemeriksaan rotor

d. Perbaikan terminal

e. Perakitan kembali

Saat dipilih:

Template langsung masuk ke SPH.

User tinggal mengisi harga.

---

DRAFT SPH

SPH dapat disimpan sebagai Draft.

Status:

Draft

Selesai

Dibatalkan

---

RIWAYAT SPH

Fitur:

Cari

Filter

Edit

Duplikasi

Export Ulang

Hapus

---

DUPLIKASI SPH

Fitur wajib.

Contoh:

SPH-001

Copy

Menjadi:

SPH-002

Seluruh pekerjaan tersalin.

User hanya mengganti:

- Customer
- Harga
- Tanggal

---

COLLAPSE & EXPAND

Untuk SPH panjang.

Contoh:

▼ I. Perbaikan Alternator

▶ I. Perbaikan Alternator

---

DRAG & DROP

User dapat mengubah urutan:

Section

Sub Item

Material

Pekerjaan

Dengan drag and drop.

---

PDF EXPORT

Generate PDF profesional.

Format:

Logo Perusahaan

Nama Perusahaan

Judul:

SURAT PENAWARAN HARGA (SPH)

Perihal

Data Customer

Tabel Pekerjaan

Rekap Total

Terbilang

Penutup

Tanda Tangan

Stempel

Ukuran:

A4 Portrait

A4 Landscape

---

EXCEL EXPORT

Fitur wajib.

Export ke:

.xlsx

Format harus sama dengan PDF.

Mendukung:

Section

Sub Item

Merge Cell

Border

Format Rupiah

Formula Excel

Total Material

Total Jasa

Subtotal

PPN

Grand Total

Terbilang

Nama file:

SPH-YYYY-NOMOR.xlsx

---

IMPORT EXCEL

Fitur wajib.

Tujuan:

Mengubah SPH Excel lama menjadi Template.

Format:

.xlsx

.xls

Data yang dibaca:

Section

Sub Item

Qty

Satuan

Material

Jasa

Harga

Jumlah

Hasil import disimpan sebagai:

Template Pekerjaan

---

PREVIEW DOKUMEN

Fitur wajib.

Saat mengedit SPH.

User dapat melihat preview:

- PDF
- Excel Layout

Secara realtime.

---

PENGATURAN

Nama Perusahaan

Alamat

Telepon

Email

Website

Logo

NPWP

Tanda Tangan

Stempel

PPN Default

Format Nomor SPH

Mata Uang

---

UI DESIGN

Konsep:

Modern Professional

Warna:

Navy Blue

White

Light Gray

Karakteristik:

- Card Based
- Minimalis
- Cepat digunakan
- Fokus produktivitas
- Nyaman digunakan satu tangan

---

PROJECT STRUCTURE

lib/

core/

database/

features/

sph/

customers/

templates/

materials/

history/

settings/

pdf/

excel/

shared/

widgets/

services/

---

NON FUNCTIONAL REQUIREMENTS

Offline 100%

Tanpa Login

Ringan

Startup < 2 Detik

Mudah Digunakan Teknisi

Kompatibel Android 8+

Tidak Membutuhkan Server

Tidak Membutuhkan Internet

---

FUTURE FEATURES

Backup Database

Google Drive Backup

Multi Perusahaan

Multi Template

Digital Signature Customer

QR Verification

Cloud Sync

Version Control Dokumen

Approval Workflow

---

FINAL OUTPUT

1. Flutter Source Code Lengkap
2. SQLite Database
3. Riverpod State Management
4. PDF Generator
5. Excel Generator
6. Excel Import
7. Master Customer
8. Master Material
9. Master Template
10. Sistem Terbilang Indonesia
11. Riwayat SPH
12. Draft SPH
13. Duplikasi SPH
14. Preview Dokumen
15. APK Siap Build

Tujuan akhir aplikasi adalah membuat SPH profesional langsung dari HP dalam waktu kurang dari 5 menit tanpa membuka Excel atau laptop, namun tetap kompatibel dengan proses kerja perusahaan yang masih menggunakan Excel.

---

## Project Structure (per 24 Juni 2026)

```
.idea
├── libraries
│   ├── Dart_SDK.xml
│   └── KotlinJavaRuntime.xml
├── runConfigurations
│   └── main_dart.xml
├── modules.xml
└── workspace.xml
android
├── .gradle
├── .kotlin
│   └── sessions
├── app
│   ├── src
│   │   ├── debug
│   │   │   └── AndroidManifest.xml
│   │   ├── main
│   │   │   ├── java/io/flutter/plugins/GeneratedPluginRegistrant.java
│   │   │   ├── kotlin/com/sph/offline/sph_offline/MainActivity.kt
│   │   │   ├── res (drawable, drawable-v21, mipmap-*, values, values-night)
│   │   │   └── AndroidManifest.xml
│   │   └── profile
│   │       └── AndroidManifest.xml
│   └── build.gradle.kts
├── gradle/wrapper (gradle-wrapper.jar, gradle-wrapper.properties)
├── build.gradle (Groovy root build with afterEvaluate)
├── gradle.properties (builtInKotlin=false)
├── settings.gradle.kts
└── local.properties
assets
└── logo/
lib
├── core
│   ├── constants/app_constants.dart
│   ├── database/database_helper.dart
│   ├── theme/app_theme.dart
│   └── utils/helpers.dart, number_to_words.dart
├── features
│   ├── customers/customer_form_screen.dart, customer_list_screen.dart, customer_picker_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── history/history_screen.dart
│   ├── materials/material_form_screen.dart, material_list_screen.dart
│   ├── settings/settings_screen.dart
│   ├── sph/sph_detail_screen.dart, sph_form_screen.dart, sph_item_edit_dialog.dart, sph_list_screen.dart
│   └── templates/template_form_screen.dart, template_list_screen.dart
├── models/company_settings.dart, customer.dart, material.dart, sph.dart, sph_item.dart, template.dart
├── providers/providers.dart (all Riverpod providers + SphFormNotifier)
├── services
│   ├── excel/excel_service.dart
│   ├── pdf/pdf_service.dart
│   ├── customer_repository.dart
│   ├── material_repository.dart
│   ├── settings_repository.dart
│   ├── sph_repository.dart
│   └── template_repository.dart
├── shared/widgets/app_drawer.dart, empty_state.dart, loading_view.dart
└── main.dart
test/widget_test.dart
pubspec.yaml, pubspec.lock
analysis_options.yaml
README.md
.metadata
```

---

*Dokumen ini diperbarui otomatis — 24 Juni 2026*