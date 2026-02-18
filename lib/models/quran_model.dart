class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  
  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });
  
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }
}

class Verse {
  final int number;
  final String text;
  final String translation;
  final int surahNumber;
  
  Verse({
    required this.number,
    required this.text,
    required this.translation,
    required this.surahNumber,
  });
  
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['numberInSurah'],
      text: json['text'],
      translation: json['translation'] ?? '',
      surahNumber: json['surah'],
    );
  }
}
