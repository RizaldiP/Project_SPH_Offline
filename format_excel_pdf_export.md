FORMAT_EXPORT_PDF_EXCEL.MD

TUJUAN

Sistem Export Excel dan PDF harus menghasilkan dokumen yang identik dengan template SPH perusahaan yang selama ini digunakan.

Output harus siap:

- Dikirim ke customer
- Dicetak
- Diarsipkan
- Dibuka kembali untuk revisi

Tanpa perlu melakukan perbaikan manual.

---

KONSEP EXPORT

Gunakan metode:

TEMPLATE DRIVEN DOCUMENT GENERATION

Bukan:

DYNAMIC DOCUMENT GENERATION

Sistem tidak membuat layout baru.

Sistem hanya mengisi template perusahaan yang sudah ada.

---

MASTER TEMPLATE

Gunakan file:

assets/templates/template_sph.xlsx

File ini menjadi sumber utama seluruh proses export.

Template berisi:

- Header
- Logo
- Border
- Merge Cell
- Formula
- Area Cetak
- Format Angka
- Terbilang
- Posisi Tanda Tangan

Template tidak boleh diubah.

Template hanya digunakan sebagai dasar pembuatan dokumen baru.

---

SINGLE SOURCE TEMPLATE

Excel dan PDF harus berasal dari template yang sama.

Alur:

Template Excel
↓
Isi Data SPH
↓
Generate Excel
↓
Convert ke PDF
↓
Generate PDF

Tujuan:

Excel dan PDF memiliki format yang identik.

---

EXCEL EXPORT

Proses:

1. Load template_sph.xlsx
2. Isi data header SPH
3. Isi data customer
4. Isi pekerjaan
5. Isi total
6. Isi terbilang
7. Simpan file baru

Output:

.xlsx

---

PDF EXPORT

Proses:

1. Load template_sph.xlsx
2. Isi data SPH
3. Isi pekerjaan
4. Isi total
5. Isi terbilang
6. Generate Excel sementara
7. Convert ke PDF

Output:

.pdf

---

FORMAT FILE NAME

Default:

SPH - [Nama Pekerjaan] - [Nama Kapal]

---

Excel

Contoh:

SPH - Perbaikan Alternator - TB Sumber Rejeki.xlsx

SPH - Perbaikan AMS Boning - KRI Bimasuci.xlsx

SPH - Penggantian Kabel Power - KM Dharma Lautan.xlsx

---

PDF

Contoh:

SPH - Perbaikan Alternator - TB Sumber Rejeki.pdf

SPH - Perbaikan AMS Boning - KRI Bimasuci.pdf

SPH - Penggantian Kabel Power - KM Dharma Lautan.pdf

---

KARAKTER TERLARANG

Sistem harus otomatis mengganti:

/

\

:

* 

?

"

<

«»

|

Menjadi:

- 

atau spasi.

---

BATAS PANJANG FILE

Maksimal:

150 karakter.

Jika lebih:

Potong otomatis tanpa menghilangkan:

- Nama Pekerjaan
- Nama Kapal

---

HEADER DOKUMEN

Mengikuti template perusahaan.

Posisi tidak boleh berubah.

Data:

- Logo
- Nama Perusahaan
- Alamat
- Telepon
- Email
- Website
- NPWP
- Nomor SPH
- Tanggal
- Perihal
- Nama Customer
- Nama Kapal

---

LOGO

Jika logo tersedia di pengaturan:

Gunakan logo tersebut.

Posisi logo harus sama dengan template.

Rasio gambar harus dipertahankan.

---

STRUKTUR TABEL

Format tabel mengikuti template perusahaan.

Kolom:

| No | Uraian Pekerjaan | Jml | Sat | Harga Satuan | Material | Jasa | Jumlah |

Tidak boleh berubah.

---

SECTION

Contoh:

I. Perbaikan Alternator

II. Penggantian Kabel

III. Material Yang Dibutuhkan

Karakteristik:

- Bold
- Merge sesuai template
- Tidak memiliki harga
- Tidak dihitung

---

ITEM PEKERJAAN

Contoh:

a. Pembongkaran Unit

b. Pembersihan Komponen

c. Pemeriksaan Rotor

d. Perakitan

Karakteristik:

- Normal
- Dapat memiliki qty
- Dapat memiliki satuan
- Dapat memiliki harga
- Dapat memiliki material
- Dapat memiliki jasa
- Dapat memiliki jumlah

---

PENOMORAN OTOMATIS

Section:

I
II
III
IV
V

Item:

a
b
c
d
e

---

FORMULA EXCEL

Formula harus tetap aktif.

Contoh:

Jumlah = Qty × Harga Satuan

atau

Harga Satuan = Material + Jasa

Jangan mengubah formula menjadi angka statis.

---

FORMAT ANGKA

Gunakan format Indonesia.

Contoh:

1.500.000

15.250.000

125.000

Tanpa desimal.

Right Align.

---

TOTAL

Bagian bawah tabel harus otomatis menampilkan:

Total Material

Total Jasa

Subtotal

Diskon

PPN

Grand Total

Menggunakan formula Excel.

---

TERBILANG

Posisi harus mengikuti template.

Contoh:

TERBILANG:

Dua Puluh Lima Juta Rupiah

Karakteristik:

- Merge Cell
- Left Align
- Mengikuti font template

---

CATATAN PENAWARAN

Mendukung multi baris.

Contoh:

- Harga belum termasuk PPN
- Masa berlaku penawaran 14 hari
- Pembayaran 50% DP

Posisi mengikuti template.

---

TANDA TANGAN

Posisi mengikuti template.

Field:

Nama Penanggung Jawab

Jabatan

Tanda Tangan Digital

Stempel Digital

---

BORDER

Gunakan border yang ada pada template.

Jangan membuat style border baru.

Jangan mengubah ketebalan border.

---

FONT

Mengikuti template perusahaan.

Ukuran font:

Mengikuti template.

Bold:

Mengikuti template.

Alignment:

Mengikuti template.

---

MERGE CELL

Semua merge cell pada template harus dipertahankan.

Tidak boleh berubah.

Tidak boleh hilang.

---

ROW HEIGHT

Mengikuti template.

Jangan menggunakan Auto Height.

---

COLUMN WIDTH

Mengikuti template.

Jangan menggunakan Auto Width.

---

PAGE SETUP

Ukuran:

A4 Landscape

Margin:

Mengikuti template.

---

PRINT AREA

Mengikuti template.

Saat dicetak:

- Tidak terpotong
- Tidak keluar margin
- Tidak merusak layout

Jika pekerjaan lebih dari satu halaman:

Lanjut otomatis ke halaman berikutnya.

---

PREVIEW DOKUMEN

Sebelum export:

User dapat melihat preview.

Preview harus menyerupai hasil Excel dan PDF.

---

MULTI TEMPLATE

Struktur aplikasi harus mendukung:

assets/templates/

template_marine.xlsx

template_electrical.xlsx

template_mechanical.xlsx

template_docking.xlsx

Saat membuat SPH:

User dapat memilih template yang ingin digunakan.

---

KUALITAS OUTPUT

Target utama:

Excel dan PDF harus terlihat sama dengan dokumen SPH perusahaan yang dibuat secara manual menggunakan Microsoft Excel.

Perbedaan visual yang dapat diterima maksimal 1%.

Pengguna harus dapat langsung mengirim hasil export ke customer tanpa melakukan editing ulang.

---

REQUIREMENT KHUSUS

Jangan membuat desain dokumen baru.

Jangan membuat format invoice.

Jangan membuat template modern.

Jangan mengubah struktur template perusahaan.

Fokus utama adalah mempertahankan format SPH perusahaan secara identik dan hanya mengganti data sesuai input pengguna.