class WordByWord {
  final String arabicText;
  final String transliteration;
  final String translation;
  final int position;

  WordByWord({
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.position,
  });

  factory WordByWord.fromJson(Map<String, dynamic> json) {
    return WordByWord(
      arabicText: json['text'] ?? '',
      transliteration: json['transliteration']?['text'] ?? '',
      translation: json['translation']?['text'] ?? '',
      position: json['position'] ?? 0,
    );
  }
}

class VerseWithWords {
  final int verseNumber;
  final String verseKey;
  final String arabicText;
  final List<WordByWord> words;

  VerseWithWords({
    required this.verseNumber,
    required this.verseKey,
    required this.arabicText,
    required this.words,
  });

  factory VerseWithWords.fromJson(Map<String, dynamic> json) {
    final verse = json['verse'];
    final wordsList = (verse['words'] as List?)
        ?.where((w) => w['char_type_name'] == 'word')
        .map((w) => WordByWord.fromJson(w))
        .toList() ?? [];
    
    return VerseWithWords(
      verseNumber: verse['verse_number'] ?? 0,
      verseKey: verse['verse_key'] ?? '',
      arabicText: verse['text_uthmani'] ?? '',
      words: wordsList,
    );
  }
}
