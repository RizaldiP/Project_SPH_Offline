# 10 — Git Workflow

Standar alur Git & GitHub untuk pengembangan **SPH Generator Mobile Offline**.

---

## 1. Branching Strategy

```
master ──┬── develop ──┬── feature/nama-fitur
       │              ├── fix/nama-bug
       │              └── refactor/nama
       │
       └── hotfix/nama-fix (langsung dari master untuk urgent)
```

| Branch | Base | Tujuan |
|--------|------|--------|
| `master` | — | Produksi (stable) |
| `develop` | `master` | Integrasi fitur |
| `feature/*` | `develop` | Fitur baru |
| `fix/*` | `develop` | Perbaikan bug |
| `refactor/*` | `develop` | Refactoring kode |
| `hotfix/*` | `master` | Fix urgent produksi |

---

## 2. Branch Naming

```
feature/tambah-customer-crud
fix/diskusi-calculasi-rounding
refactor/extract-sph-form-notifier
hotfix/crash-null-customer
docs/tambah-database-schema
chore/update-dependencies
```

Aturan:
- Gunakan **kebab-case**.
- Bahasa **Indonesia** untuk nama branch (karena konteks project lokal).
- Satu branch = satu tujuan (jangan campur fitur dan fix).

---

## 3. Commit Message Convention

Format: `type: deskripsi singkat`

Gunakan **bahasa Inggris** untuk commit message.

| Type | Keterangan |
|------|-----------|
| `feat` | Fitur baru |
| `fix` | Perbaikan bug |
| `refactor` | Refactoring (tanpa perubahan behavior) |
| `docs` | Dokumentasi |
| `chore` | Tugas maintenance (dependencies, config) |
| `style` | Formatting, whitespace (bukan logika) |
| `test` | Menambah/memperbaiki test |

### Contoh

```
feat: add CRUD customer with search
fix: fix discount calculation rounding error
refactor: extract SphFormNotifier from providers.dart
docs: add database schema documentation
chore: update flutter_riverpod to 2.6.1
```

Aturan:
- Maksimal **72 karakter** per baris.
- Gunakan **imperative mood** ("add" bukan "added" / "adds").
- Jika perlu detail, tambahkan body setelah 1 baris kosong.

---

## 4. Workflow Harian

```bash
# 1. Update branch master
git checkout master
git pull origin master

# 2. Buat branch fitur
git checkout -b feature/nama-fitur

# 3. Coding & commit
git add .
git commit -m "feat: add customer CRUD"

# 4. Push ke remote
git push origin feature/nama-fitur

# 5. Buat Pull Request ke master (via GitHub)
```

---

## 5. Pull Request (PR)

### Judul PR
Gunakan format seperti commit message:
```
feat: add customer CRUD
```

### Template Deskripsi
```markdown
## Deskripsi
<!-- Jelaskan apa yang diubah dan kenapa -->

## Screenshot (jika ada)
<!-- Lampirkan screenshot sebelum/sesudah -->

## Checklist
- [ ] Kode sudah di-`flutter analyze`
- [ ] Tidak ada warning/error baru
- [ ] Sudah di-test di device
- [ ] Database migration backward compatible
```

### Review Rules
- Minimal 1 approval sebelum merge ke `develop`.
- Jangan self-merge.
- PR ke `master` harus dari `develop` yang sudah di-test.

---

## 6. Merge Strategy

- **Feature → Develop**: `Squash & Merge` (1 commit per fitur).
- **Develop → Master**: `Merge Commit` (history tetap utuh).
- **Hotfix → Master**: `Squash & Merge`.

---

## 7. .gitignore

File yang sudah di-ignore:

```
.idea/
.dart_tool/
build/
.pub-cache/
*.iml
*.log
```

Lihat `.gitignore` untuk daftar lengkap.

---

## 8. Tagging & Version

Gunakan semantic versioning: `v1.0.0`

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

Format: `v{major}.{minor}.{patch}` (sesuai `pubspec.yaml`).

---

## 9. Aturan Tambahan

- **Jangan commit** file `.db` atau database hasil debugging.
- **Jangan commit** keystore (`*.jks`, `*.keystore`).
- **Jangan commit** `local.properties` atau file konfigurasi lokal.
- Selalu `git pull` sebelum mulai bekerja untuk menghindari conflict.
- Jika conflict terjadi, selesaikan di branch fitur, bukan di `develop`.
