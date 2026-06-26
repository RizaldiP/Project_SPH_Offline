import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(num value) {
    final format = NumberFormat('#,##0', 'id_ID');
    return 'Rp${format.format(value)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String generateSphNumber(int count) {
    final year = DateTime.now().year.toString();
    return 'SPH-$year-${count.toString().padLeft(3, '0')}';
  }
}
