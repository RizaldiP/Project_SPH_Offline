# 01 — Setup & Instalasi

Panduan untuk menjalankan project **SPH Generator Mobile Offline** dari nol di lokal.

---

## 1. Prasyarat

| Tool | Versi Minimal | Catatan |
|------|--------------|---------|
| **Flutter SDK** | ^3.12.1 | Gunakan channel `stable` |
| **Dart SDK** | ^3.12.1 | Bundling dengan Flutter |
| **Git** | 2.x | Version control |
| **Android Studio** | Hedgehog+ | Untuk emulator & build Android |
| **Visual Studio Code** | Terbaru | Opsional, editor alternatif |

Cek instalasi:

```bash
flutter --version
dart --version
git --version
```

---

## 2. Clone Repository

```bash
git clone <repository-url> project-sph-offline
cd project-sph-offline/sph_offline
```

> Struktur: folder utama `project-sph-offline/` berisi `docs/` dan `sph_offline/` (project Flutter).

---

## 3. Install Dependencies

```bash
# Di dalam folder sph_offline/
flutter pub get
```

Perintah ini akan mengunduh semua dependency dari `pubspec.yaml`, termasuk override lokal di `packages/excel`.

Dependencies utama:
- `flutter_riverpod` — State management
- `sqflite` — Database SQLite
- `pdf` + `printing` — Generate & print PDF
- `excel` (local override) — Baca/tulis Excel
- `file_picker` — Import file
- `image_picker` — Upload logo/tanda tangan

---

## 4. Persiapan Device / Emulator

### 4.1 Android Emulator (Android Studio)

```bash
# List available emulators
flutter emulators

# Jalankan emulator
flutter emulators --launch <emulator_id>

# Cek device terhubung
flutter devices
```

### 4.2 Physical Android Device (USB)

1. Aktifkan **Developer Options** dan **USB Debugging** di HP.
2. Hubungkan via USB.
3. Pastikan terdeteksi:
   ```bash
   flutter devices
   ```

> **Penting:** Jangan gunakan `flutter install` karena akan **uninstall ulang** dan menghapus database. Gunakan `flutter run` untuk update safe.

---

## 5. Menjalankan Aplikasi

### 5.1 Run (dengan hot reload)

```bash
flutter run
```

Untuk device spesifik:

```bash
flutter devices
flutter run --device-id <ID>
```

### 5.2 Build APK (release)

```bash
flutter build apk --release
```

Hasil build: `build/app/outputs/flutter-apk/app-release.apk`

### 5.3 Build App Bundle (Play Store)

```bash
flutter build appbundle --release
```

---

## 6. Debugging

### 6.1 Analyze code

```bash
flutter analyze
```

### 6.2 Run tests

```bash
flutter test
```

### 6.3 Code generation (jika ada perubahan provider)

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 7. Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `flutter pub get` gagal | Coba `flutter clean` lalu `flutter pub get` |
| Database hilang setelah install | Gunakan `flutter run --device-id <ID>`, bukan `flutter install` |
| Error build Gradle | Buka `android/` di Android Studio, biarkan sync Gradle |
| Hot reload tidak jalan | Gunakan hot restart: tekan `R` di terminal `flutter run` |
