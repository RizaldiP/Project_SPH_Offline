# 03 — Coding Standard

Aturan penulisan kode untuk **SPH Generator Mobile Offline**. Tujuan: kode bersih, konsisten, dan mudah dipelihara.

---

## 1. Bahasa

- **Kode**: Gunakan bahasa Inggris untuk nama kelas, fungsi, variabel, komentar, commit.
- **UI / User-facing string**: Gunakan bahasa Indonesia (karena aplikasi untuk pasar Indonesia).

---

## 2. Naming Conventions

| Elemen | Convention | Contoh |
|--------|-----------|--------|
| **Class** | `PascalCase` | `SphFormNotifier`, `DatabaseHelper` |
| **Enum** | `PascalCase` | `enum SphStatus { draft, selesai }` |
| **Function / Method** | `camelCase` | `calculateTotals()`, `getAll()` |
| **Variable (local)** | `camelCase` | `final sphList`, `String? customerName` |
| **Variable (private)** | `_camelCase` | `_database`, `insertDefaultMappings()` |
| **Constant** | `camelCase` | `static const navyBlue` (atau SCREAMING_SNAKE untuk konstanta global) |
| **File** | `snake_case.dart` | `sph_form_screen.dart`, `database_helper.dart` |
| **Folder** | `snake_case/` | `sph/`, `customers/`, `excel/` |
| **DB Column** | `snake_case` | `customer_id`, `total_material` |
| **JSON key** | `camelCase` | (dalam Dart map) |

---

## 3. Folder Structure

```
lib/
├── main.dart                         # Entry point
├── core/                             # Cross-cutting concerns
│   ├── constants/
│   ├── database/
│   ├── theme/
│   └── utils/
├── models/                           # Data classes (immutable)
├── providers/                        # Riverpod providers
├── services/                         # Repositories & services
│   ├── excel/
│   └── pdf/
├── features/                         # Feature modules
│   ├── sph/
│   ├── customers/
│   ├── materials/
│   ├── templates/
│   ├── history/
│   ├── dashboard/
│   └── settings/
└── shared/widgets/                   # Reusable widgets
```

### Aturan Folder

- Setiap **feature** punya folder sendiri.
- Tidak ada folder `screens/` global — screen milik feature masing-masing.
- Widget yang dipakai di banyak feature masuk ke `shared/widgets/`.

---

## 4. Model (Data Class)

- **Immutable**: semua field `final`.
- **`copyWith()`**: wajib ada untuk memudahkan update StateNotifier.
- **`toMap()` / `fromMap()`**: untuk serialisasi SQLite.
- **Gunakan `int` untuk harga** (hindari floating point error).

```dart
class Customer {
  final int? id;
  final String name;
  // ...

  const Customer({this.id, required this.name, ...});

  Map<String, dynamic> toMap() => {...};
  factory Customer.fromMap(Map<String, dynamic> map) => ...;
  Customer copyWith({...}) => ...;
}
```

---

## 5. State Management (Riverpod)

- **Gunakan `Provider`** untuk singleton service.
- **Gunakan `FutureProvider`** untuk async data (list customer, dll).
- **Gunakan `FutureProvider.family`** untuk parameterized query.
- **Gunakan `StateNotifierProvider`** untuk form state kompleks.
- Naming pattern: `sphFormProvider` → StateNotifierProvider, `customersProvider` → FutureProvider.

### Aturan

- **Jangan** simpan state di widget. Semua state via Riverpod.
- **Invalidate provider** setelah operasi CRUD: `_ref.invalidate(providerName)`.
- Provider hanya di satu file: `lib/providers/providers.dart`.

---

## 6. Service / Repository

- Repository pattern: setiap entity punya repository sendiri.
- Method naming:
  - `getAll()` → List semua
  - `getById(int id)` → By ID
  - `insert(obj)` → Insert
  - `update(obj)` → Update
  - `delete(int id)` → Delete
- Repository tidak manggil repository lain.
- Semua method repository bersifat `async`.

---

## 7. Widget & UI

- **Screen**: file `*_screen.dart` di folder feature.
- **Dialog**: file `*_dialog.dart` di folder feature.
- **Widget reusable**: di `shared/widgets/`.
- Gunakan `const constructor` sebisa mungkin.
- Hindari logic bisnis di widget — pindahkan ke provider/notifier.

---

## 8. Database

- Akses database hanya melalui `DatabaseHelper.instance.database`.
- Semua operasi DB via repository, jangan di screen.
- Migration: tambahkan di `_onUpgrade()`, buat konstanta versi baru di `AppConstants`.

---

## 9. Imports

Urutan import:

```dart
import 'package:flutter/material.dart';        // 1. Flutter / packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer.dart';               // 2. Internal project
import '../services/customer_repository.dart';
```

Hapus import yang tidak dipakai.

---

## 10. Linting

Gunakan pengaturan default `flutter_lints` di `analysis_options.yaml`. Jalankan:

```bash
flutter analyze
```

Sebelum commit, pastikan tidak ada `error` atau `warning` baru.

---

## 11. Git Commit

- Bahasa: **Inggris** untuk pesan commit.
- Format: `type: deskripsi singkat`
  - `feat: add CRUD customer`
  - `fix: fix discount calculation rounding`
  - `refactor: extract SphFormNotifier from providers`
  - `docs: add database schema documentation`
  - `chore: update dependencies`
- Maksimal 72 karakter per baris.
- Jangan commit file build (`.dart_tool/`, `build/`).

---

## 12. Prinsip Clean Code

| Prinsip | Penerapan |
|---------|-----------|
| **KISS** | Jangan over-engineer. Fungsi sederhana > abstraksi berlebihan. |
| **DRY** | Extract reusable code ke fungsi/widget terpisah. |
| **Single Responsibility** | 1 class = 1 tanggung jawab. Screen hanya render UI. |
| **Immutability** | Model & state bersifat immutable. Copy, jangan mutate. |
| **Separation of Concerns** | UI ↔ Logic ↔ Data dipisah rapi (Riverpod pattern). |
