class ArabicLetter {
  final String arabic;
  final String name;
  final String transliteration;
  final String pronunciation;
  final List<String> examples;

  ArabicLetter({
    required this.arabic,
    required this.name,
    required this.transliteration,
    required this.pronunciation,
    required this.examples,
  });
}

class Harakat {
  final String name;
  final String symbol;
  final String description;
  final String example;
  final String sound;

  Harakat({
    required this.name,
    required this.symbol,
    required this.description,
    required this.example,
    required this.sound,
  });
}

class ArabicAlphabetData {
  static final List<ArabicLetter> letters = [
    ArabicLetter(arabic: 'ا', name: 'Alif', transliteration: 'A', pronunciation: 'aa', examples: ['أَسَد', 'إِبْرَة']),
    ArabicLetter(arabic: 'ب', name: 'Ba', transliteration: 'B', pronunciation: 'ba', examples: ['بَيْت', 'كِتَاب']),
    ArabicLetter(arabic: 'ت', name: 'Ta', transliteration: 'T', pronunciation: 'ta', examples: ['تُفَّاح', 'بِنْت']),
    ArabicLetter(arabic: 'ث', name: 'Tha', transliteration: 'Th', pronunciation: 'tha', examples: ['ثَوْب', 'ثَلَاثَة']),
    ArabicLetter(arabic: 'ج', name: 'Jeem', transliteration: 'J', pronunciation: 'ja', examples: ['جَمَل', 'مَسْجِد']),
    ArabicLetter(arabic: 'ح', name: 'Ha', transliteration: 'H', pronunciation: 'ha', examples: ['حَمَام', 'صَبَاح']),
    ArabicLetter(arabic: 'خ', name: 'Kha', transliteration: 'Kh', pronunciation: 'kha', examples: ['خُبْز', 'تَارِيخ']),
    ArabicLetter(arabic: 'د', name: 'Dal', transliteration: 'D', pronunciation: 'da', examples: ['دَجَاج', 'أَحَد']),
    ArabicLetter(arabic: 'ذ', name: 'Dhal', transliteration: 'Dh', pronunciation: 'dha', examples: ['ذَهَب', 'أُسْتَاذ']),
    ArabicLetter(arabic: 'ر', name: 'Ra', transliteration: 'R', pronunciation: 'ra', examples: ['رَجُل', 'نَهْر']),
    ArabicLetter(arabic: 'ز', name: 'Zay', transliteration: 'Z', pronunciation: 'za', examples: ['زَيْت', 'خُبْز']),
    ArabicLetter(arabic: 'س', name: 'Seen', transliteration: 'S', pronunciation: 'sa', examples: ['سَمَك', 'شَمْس']),
    ArabicLetter(arabic: 'ش', name: 'Sheen', transliteration: 'Sh', pronunciation: 'sha', examples: ['شَجَر', 'عَيْش']),
    ArabicLetter(arabic: 'ص', name: 'Sad', transliteration: 'S', pronunciation: 'sa', examples: ['صَبَاح', 'قَصْر']),
    ArabicLetter(arabic: 'ض', name: 'Dad', transliteration: 'D', pronunciation: 'da', examples: ['ضَوْء', 'أَرْض']),
    ArabicLetter(arabic: 'ط', name: 'Ta', transliteration: 'T', pronunciation: 'ta', examples: ['طَعَام', 'خَطّ']),
    ArabicLetter(arabic: 'ظ', name: 'Dha', transliteration: 'Dh', pronunciation: 'dha', examples: ['ظُهْر', 'حَظّ']),
    ArabicLetter(arabic: 'ع', name: 'Ain', transliteration: 'A', pronunciation: 'aa', examples: ['عَيْن', 'جَمِيع']),
    ArabicLetter(arabic: 'غ', name: 'Ghain', transliteration: 'Gh', pronunciation: 'gha', examples: ['غُرَاب', 'بَلَاغ']),
    ArabicLetter(arabic: 'ف', name: 'Fa', transliteration: 'F', pronunciation: 'fa', examples: ['فِيل', 'صَيْف']),
    ArabicLetter(arabic: 'ق', name: 'Qaf', transliteration: 'Q', pronunciation: 'qa', examples: ['قَلَم', 'حَقّ']),
    ArabicLetter(arabic: 'ك', name: 'Kaf', transliteration: 'K', pronunciation: 'ka', examples: ['كَلْب', 'مَلِك']),
    ArabicLetter(arabic: 'ل', name: 'Lam', transliteration: 'L', pronunciation: 'la', examples: ['لَيْل', 'جَمَل']),
    ArabicLetter(arabic: 'م', name: 'Meem', transliteration: 'M', pronunciation: 'ma', examples: ['مَاء', 'قَلَم']),
    ArabicLetter(arabic: 'ن', name: 'Noon', transliteration: 'N', pronunciation: 'na', examples: ['نَار', 'عَيْن']),
    ArabicLetter(arabic: 'ه', name: 'Ha', transliteration: 'H', pronunciation: 'ha', examples: ['هِلَال', 'اللّٰه']),
    ArabicLetter(arabic: 'و', name: 'Waw', transliteration: 'W', pronunciation: 'wa', examples: ['وَرْد', 'نُور']),
    ArabicLetter(arabic: 'ي', name: 'Ya', transliteration: 'Y', pronunciation: 'ya', examples: ['يَد', 'عَلِي']),
  ];

  static final List<Harakat> harakat = [
    Harakat(
      name: 'Fatha (Zabar)',
      symbol: 'َ',
      description: 'Short "a" sound',
      example: 'بَ',
      sound: 'ba',
    ),
    Harakat(
      name: 'Kasra (Zer)',
      symbol: 'ِ',
      description: 'Short "i" sound',
      example: 'بِ',
      sound: 'bi',
    ),
    Harakat(
      name: 'Damma (Pesh)',
      symbol: 'ُ',
      description: 'Short "u" sound',
      example: 'بُ',
      sound: 'bu',
    ),
    Harakat(
      name: 'Sukoon (Jazm)',
      symbol: 'ْ',
      description: 'No vowel sound',
      example: 'بْ',
      sound: 'b',
    ),
    Harakat(
      name: 'Tanween Fath',
      symbol: 'ً',
      description: 'Double fatha - "an"',
      example: 'بً',
      sound: 'ban',
    ),
    Harakat(
      name: 'Tanween Kasr',
      symbol: 'ٍ',
      description: 'Double kasra - "in"',
      example: 'بٍ',
      sound: 'bin',
    ),
    Harakat(
      name: 'Tanween Damm',
      symbol: 'ٌ',
      description: 'Double damma - "un"',
      example: 'بٌ',
      sound: 'bun',
    ),
    Harakat(
      name: 'Shadda (Tashdeed)',
      symbol: 'ّ',
      description: 'Double letter',
      example: 'بَّ',
      sound: 'bba',
    ),
    Harakat(
      name: 'Madd',
      symbol: 'ٰ',
      description: 'Long vowel',
      example: 'بَا',
      sound: 'baa',
    ),
  ];
}
