class Hadith {
  final String book;
  final String hadithNumber;
  final String arabicText;
  final String englishText;
  final String narrator;

  Hadith({
    required this.book,
    required this.hadithNumber,
    required this.arabicText,
    required this.englishText,
    required this.narrator,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      book: json['book'] ?? '',
      hadithNumber: json['hadithNumber']?.toString() ?? '',
      arabicText: json['hadithArabic'] ?? '',
      englishText: json['hadithEnglish'] ?? '',
      narrator: json['englishNarrator'] ?? '',
    );
  }
}
