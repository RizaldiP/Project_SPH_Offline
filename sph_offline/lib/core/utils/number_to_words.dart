class NumberToWords {
  static final List<String> _units = [
    '', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan'
  ];
  static final List<String> _tens = [
    '', 'sepuluh', 'dua puluh', 'tiga puluh', 'empat puluh', 'lima puluh',
    'enam puluh', 'tujuh puluh', 'delapan puluh', 'sembilan puluh'
  ];
  static final List<String> _teens = [
    'sepuluh', 'sebelas', 'dua belas', 'tiga belas', 'empat belas', 'lima belas',
    'enam belas', 'tujuh belas', 'delapan belas', 'sembilan belas'
  ];
  static final List<String> _thousands = [
    '', 'ribu', 'juta', 'milyar', 'triliun'
  ];

  static String convert(int number) {
    if (number == 0) return 'nol';

    String result = '';
    int num = number;
    int thousandIndex = 0;

    while (num > 0) {
      int segment = num % 1000;
      if (segment > 0) {
        String segmentStr = _convertSegment(segment, thousandIndex);
        result = '$segmentStr ${_thousands[thousandIndex]} $result';
      }
      num ~/= 1000;
      thousandIndex++;
    }

    return '${result.trim()} rupiah';
  }

  static String _convertSegment(int number, int index) {
    String result = '';

    if (number >= 100) {
      int hundreds = number ~/ 100;
      if (hundreds == 1) {
        result += 'seratus ';
      } else {
        result += '${_units[hundreds]} ratus ';
      }
      number %= 100;
    }

    if (number >= 20) {
      int tens = number ~/ 10;
      result += '${_tens[tens]} ';
      number %= 10;
    } else if (number >= 10) {
      result += '${_teens[number - 10]} ';
      number = 0;
    }

    if (number > 0) {
      if (index == 1 && number == 1) {
        result += 'se';
      } else {
        result += '${_units[number]} ';
      }
    }

    return result.trim();
  }
}
