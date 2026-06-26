# 02 — Database

Dokumentasi struktur database SQLite aplikasi **SPH Generator Mobile Offline**.

---

## 1. Informasi Umum

| Item | Nilai |
|------|-------|
| **DBMS** | SQLite (via `sqflite`) |
| **Nama File** | `sph_offline.db` |
| **Lokasi** | `getDatabasesPath()` |
| **Version** | 2 |
| **Singleton** | `DatabaseHelper.instance` |
| **Inisialisasi** | Lazy (saat pertama kali dipanggil) |

---

## 2. Entity Relationship Diagram

```
settings (1) ─── (singleton, max 1 row)

customers (1) ──── (0..N) sph

materials (0..N)   (auto-save dari SPH)

sph_templates (1) ──── (0..N) sph_template_items
                        (parent_id self-ref)

sph (1) ──── (0..N) sph_items
                    (parent_id self-ref)

master_template (1) ──── (0..N) cell_mapping
```

---

## 3. Struktur Tabel

### 3.1 `settings`

Menyimpan profil perusahaan (single row).

| Kolom | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `id` | INTEGER PK | AUTOINCREMENT | |
| `company_name` | TEXT | `'Perusahaan Saya'` | Nama perusahaan |
| `address` | TEXT | `null` | Alamat |
| `phone` | TEXT | `null` | Telepon |
| `email` | TEXT | `null` | Email |
| `website` | TEXT | `null` | Website |
| `logo_path` | TEXT | `null` | Path file logo |
| `signature_path` | TEXT | `null` | Path file tanda tangan |
| `stamp_path` | TEXT | `null` | Path file stempel |
| `npwp` | TEXT | `null` | NPWP |
| `default_ppn` | TEXT | `'11'` | PPN default (%) |
| `sph_number_format` | TEXT | `'SPH-YYYY-NNN'` | Format nomor SPH |
| `currency` | TEXT | `'Rp'` | Mata uang |
| `signature_name` | TEXT | `null` | Nama penandatangan *(v2)* |
| `signature_position` | TEXT | `null` | Jabatan penandatangan *(v2)* |
| `notes` | TEXT | `null` | Catatan kaki *(v2)* |

### 3.2 `customers`

Data master pelanggan.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PK | AUTOINCREMENT |
| `name` | TEXT NOT NULL | Nama PIC / kontak |
| `company_name` | TEXT | Nama perusahaan |
| `address` | TEXT | Alamat |
| `phone` | TEXT | Telepon |
| `email` | TEXT | Email |
| `pic` | TEXT | Person in charge |
| `notes` | TEXT | Catatan |
| `created_at` | TEXT | ISO 8601 |
| `updated_at` | TEXT | ISO 8601 |

### 3.3 `materials`

Data master material (auto-populated dari item SPH).

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PK | AUTOINCREMENT |
| `name` | TEXT NOT NULL | Nama material |
| `category` | TEXT | Kategori |
| `unit` | TEXT | Satuan (buah, meter, dll) |
| `standard_price` | REAL DEFAULT 0 | Harga standar |
| `supplier` | TEXT | Supplier |
| `notes` | TEXT | Catatan |
| `created_at` | TEXT | ISO 8601 |
| `updated_at` | TEXT | ISO 8601 |

### 3.4 `sph_templates`

Header template pekerjaan (otomatis dari section SPH yang punya jasa).

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PK | AUTOINCREMENT |
| `name` | TEXT NOT NULL | Nama template |
| `description` | TEXT | Deskripsi |
| `created_at` | TEXT | ISO 8601 |
| `updated_at` | TEXT | ISO 8601 |

### 3.5 `sph_template_items`

Item dalam template pekerjaan (self-referencing parent untuk section → item).

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PK | AUTOINCREMENT |
| `template_id` | INTEGER NOT NULL | FK → `sph_templates.id` CASCADE |
| `type` | TEXT NOT NULL | `'section'` atau `'item'` |
| `label` | TEXT NOT NULL | Nama section/item |
| `parent_id` | INTEGER | FK → `sph_template_items.id` CASCADE |
| `sort_order` | INTEGER DEFAULT 0 | Urutan tampilan |
| `default_unit` | TEXT | Satuan default |

### 3.6 `sph`

Header dokumen Surat Penawaran Harga.

| Kolom | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `id` | INTEGER PK | AUTOINCREMENT | |
| `number` | TEXT NOT NULL | | Nomor SPH |
| `title` | TEXT | `null` | Perihal |
| `date` | TEXT | `null` | Tanggal SPH |
| `customer_id` | INTEGER | `null` | FK → `customers.id` |
| `customer_name` | TEXT | `null` | Snapshot nama |
| `customer_company` | TEXT | `null` | Snapshot perusahaan |
| `customer_address` | TEXT | `null` | Snapshot alamat |
| `customer_pic` | TEXT | `null` | Snapshot PIC |
| `ship_name` | TEXT | `null` | Nama kapal/proyek |
| `validity_period` | TEXT | `null` | Masa berlaku |
| `notes` | TEXT | `null` | Catatan |
| `discount` | REAL | 0 | Diskon (%) |
| `ppn` | REAL | 11 | PPN (%) |
| `status` | TEXT | `'draft'` | `'draft'` / `'selesai'` |
| `total_material` | REAL | 0 | Total harga material |
| `total_jasa` | REAL | 0 | Total harga jasa |
| `subtotal` | REAL | 0 | Subtotal (material + jasa) |
| `grand_total` | REAL | 0 | Grand total (setelah diskon & PPN) |
| `created_at` | TEXT | | ISO 8601 |
| `updated_at` | TEXT | | ISO 8601 |

### 3.7 `sph_items`

Item pekerjaan dalam SPH (self-referencing parent untuk section → item).

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PK | AUTOINCREMENT |
| `sph_id` | INTEGER NOT NULL | FK → `sph.id` CASCADE |
| `type` | TEXT NOT NULL | `'section'` atau `'item'` |
| `label` | TEXT NOT NULL | Nama section/item |
| `parent_id` | INTEGER | FK → `sph_items.id` CASCADE |
| `sort_order` | INTEGER DEFAULT 0 | Urutan tampilan |
| `qty` | REAL DEFAULT 0 | Quantity |
| `unit` | TEXT | Satuan |
| `material_price` | REAL DEFAULT 0 | Harga material per unit |
| `jasa_price` | REAL DEFAULT 0 | Harga jasa per unit |
| `unit_price` | REAL DEFAULT 0 | Unit price (material + jasa) |
| `total_price` | REAL DEFAULT 0 | Total harga (qty × unit_price) |

### 3.8 `master_template`

Template Excel yang di-upload (singleton — hanya satu active).

| Kolom | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `id` | INTEGER PK | AUTOINCREMENT | |
| `file_name` | TEXT NOT NULL | | Nama file Excel |
| `file_path` | TEXT NOT NULL | | Path file di storage |
| `sheet_name` | TEXT | `'Sheet1'` | Nama sheet |
| `is_active` | INTEGER | 1 | 1 = active |
| `created_at` | TEXT | | ISO 8601 |
| `updated_at` | TEXT | | ISO 8601 |

### 3.9 `cell_mapping`

Mapping cell Excel ke field SPH.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PK | AUTOINCREMENT |
| `field_name` | TEXT NOT NULL | Nama field SPH |
| `cell_address` | TEXT | Alamat cell (misal `B3`) |
| `is_table_field` | INTEGER DEFAULT 0 | 0 = header, 1 = table |
| `table_start_row` | INTEGER | Row awal tabel |
| `table_column` | TEXT | Kolom tabel (misal `C`) |
| `prototype_row` | INTEGER | Row prototipe |

**Field yang dimapping:**

**Header fields** (`is_table_field = 0`):
`sph_number`, `sph_date`, `perihal`, `customer_name`, `customer_company`, `customer_address`, `ship_name`, `validity_period`, `notes`, `total_material`, `total_jasa`, `subtotal`, `discount`, `ppn`, `grand_total`, `terbilang`, `sign_name`, `sign_position`

**Table fields** (`is_table_field = 1`):
`table_label`, `table_qty`, `table_unit`, `table_unit_price`, `table_material`, `table_jasa`, `table_amount`

---

## 4. Migration

### v1 → v2

```sql
ALTER TABLE settings ADD COLUMN signature_name TEXT;
ALTER TABLE settings ADD COLUMN signature_position TEXT;
ALTER TABLE settings ADD COLUMN notes TEXT;

CREATE TABLE master_template (...);
CREATE TABLE cell_mapping (...);
```

---

## 5. Relasi & Constraints

| FK | Table | Referensi | On Delete |
|----|-------|-----------|-----------|
| `sph.customer_id` | sph | customers.id | — (SET NULL) |
| `sph_items.sph_id` | sph_items | sph.id | CASCADE |
| `sph_items.parent_id` | sph_items | sph_items.id | CASCADE |
| `sph_template_items.template_id` | sph_template_items | sph_templates.id | CASCADE |
| `sph_template_items.parent_id` | sph_template_items | sph_template_items.id | CASCADE |

---

## 6. Data Awal (Seeder)

Saat `_onCreate`, aplikasi mengisi:

- **`settings`**: 1 baris default `company_name = 'Perusahaan Saya'`, `default_ppn = '11'`
- **`cell_mapping`**: 17 header fields + 7 table fields (semua `cell_address = null`, diatur manual oleh user via UI)
