# Project Notes

## Debugging on Android Device (USB Cable)

- **ALWAYS use `flutter run --device-id <ID>`** — jangan pakai `flutter build` + `flutter install` karena `flutter install` akan **uninstall dulu** (hapus database) lalu install ulang.
- `flutter run` melakukan upgrade tanpa menghapus data, jadi mapping/cell settings tetap aman.

## File Structure

- `lib/services/excel/excel_service.dart` — export Excel
- `lib/services/pdf/pdf_service.dart` — export PDF
- `lib/providers/providers.dart` — auto-save template dedup logic
- `lib/features/templates/template_list_screen.dart` — search + bulk delete
- `lib/services/template_repository.dart` — CRUD template pekerjaan
