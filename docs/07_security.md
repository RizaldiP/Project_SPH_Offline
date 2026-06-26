# 07 — Security Checklist

Checklist keamanan untuk **SPH Generator Mobile Offline**.

> Aplikasi ini **100% offline** (tidak ada koneksi internet untuk data), sehingga attack surface terbatas. Fokus keamanan ada pada data-at-rest, input validation, dan file handling.

---

## 1. Data-at-Rest (SQLite)

- [x] Database disimpan di `getDatabasesPath()` (app-private directory).
- [x] Tidak ada data sensitif tingkat tinggi (password, token, API key).
- [ ] **Opsional**: Enkripsi database dengan `sqflite_sqlcipher` jika data dianggap sangat rahasia.
- [ ] **Opsional**: Backup file database bisa di-encrypt sebelum di-share.

---

## 2. File Storage

- [x] Logo, signature, stamp disimpan di app-private directory via `path_provider`.
- [x] File Excel template juga di app-private directory.
- [ ] **Perlu perhatian**: Saat export PDF/Excel menggunakan `share_plus`, file sementara disimpan di folder publik (cache). Pastikan file dibersihkan setelah di-share.
- [x] File picker menggunakan `file_picker` yang hanya mengakses file yang dipilih user.

---

## 3. Input Validation

- [ ] **Belum ada validasi** untuk field numerik (qty, harga). Pastikan input numeric tidak menyebabkan overflow atau NaN.
- [x] ID parameter menggunakan integer (SQLite), mengurangi risiko SQL injection.
- [ ] Data customer/material bebas teks — berpotensi XSS jika di-render di WebView. Saat ini tidak ada WebView, jadi risiko rendah.

### Yang perlu ditambahkan:

```dart
// Contoh validasi numerik
if (qty < 0 || qty > 999999999) {
  throw ArgumentError('Quantity out of range');
}
if (price < 0) {
  throw ArgumentError('Price cannot be negative');
}
```

---

## 4. SQL Injection

- [x] Menggunakan `sqflite` dengan parameterized query (rawQuery dengan `?` placeholder).
- [ ] **Periksa** semua query di repository — pastikan tidak ada string concatenation untuk nilai user input.

✅ **Aman**:
```dart
await db.query('customers', where: 'name LIKE ?', whereArgs: ['%$query%']);
```

❌ **Tidak aman**:
```dart
await db.rawQuery("SELECT * FROM customers WHERE name LIKE '%$query%'");
```

---

## 5. File Upload (Import)

- [x] File picker membatasi tipe: hanya `.xlsx` untuk Excel, `.png`/`.jpg` untuk gambar.
- [ ] **Validasi ukuran file**: tambahkan batas maksimal (misal 10MB) untuk file yang di-import.
- [ ] **Validasi konten**: pastikan file Excel benar-benar Excel (bukan file berbahaya yang diganti ekstensi).

```dart
// Tambahkan validasi di service
const maxFileSize = 10 * 1024 * 1024; // 10MB
final fileSize = await file.length();
if (fileSize > maxFileSize) throw Exception('File terlalu besar');
```

---

## 6. Sharing Data

- [ ] Saat export PDF/Excel menggunakan `share_plus`, data dikirim melalui intent Android — pastikan tidak ada data yang bocor ke aplikasi lain yang tidak diinginkan.

---

## 7. Build & Release

- [x] Aplikasi menggunakan `--release` untuk distribusi.
- [ ] **ProGuard / R8**: aktifkan code obfuscation di `android/app/build.gradle.kts`:

```kotlin
android {
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

- [ ] **Signing**: pastikan APK/AAB di-sign dengan keystore yang aman (jangan commit ke repo).

---

## 8. Dependency

- [x] Semua dependency dari pub.dev (official).
- [x] Excel menggunakan local override (`packages/excel`).
- [ ] **Rutin update dependency** untuk patch keamanan:
  ```bash
  flutter pub outdated
  flutter pub upgrade
  ```

---

## 9. Logging & Debug

- [x] Mode debug bisa dimatikan di `main.dart` (tidak ada `debugShowCheckedModeBanner`).
- [ ] Hapus `print()` / `debugPrint()` sebelum rilis.
- [ ] Jangan log data sensitif ke console.

---

## 10. Checklist Keseluruhan

| # | Item | Status |
|---|------|--------|
| 1 | Database di private directory | ✅ |
| 2 | Parameterized query SQL | ✅ |
| 3 | File picker batasi tipe file | ✅ |
| 4 | Validasi input numerik | ⚠️ Perlu ditambah |
| 5 | Validasi ukuran file upload | ⚠️ Perlu ditambah |
| 6 | Hapus debug print sebelum rilis | ⚠️ Perlu review |
| 7 | ProGuard obfuscation | ⚠️ Perlu diaktifkan |
| 8 | Update dependency rutin | ⚠️ Perlu jadwal |
| 9 | Enkripsi database (opsional) | ❌ Belum |
