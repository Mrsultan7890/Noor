class ArabicCourseContent {
  const ArabicCourseContent({
    required this.levels,
    required this.isOffline,
  });

  final List<ArabicCourseLevel> levels;
  final bool isOffline;
}

class ArabicCourseLevel {
  const ArabicCourseLevel({
    required this.id,
    required this.order,
    required this.title,
    required this.lessons,
    required this.quizPrompt,
  });

  final String id;
  final int order;
  final String title;
  final List<ArabicCourseLesson> lessons;
  final String quizPrompt;
}

class ArabicCourseLesson {
  const ArabicCourseLesson({
    required this.id,
    required this.order,
    required this.title,
    required this.objective,
    required this.instruction,
    required this.items,
    required this.quizQuestionCount,
    required this.chart,
  });

  final String id;
  final int order;
  final String title;
  final String objective;
  final String instruction;
  final List<ArabicCourseItem> items;
  final int quizQuestionCount;
  final Map<String, String> chart;
}

class ArabicCourseItem {
  const ArabicCourseItem({
    required this.id,
    required this.type,
    required this.arabic,
    required this.transliteration,
    required this.audioPath,
    required this.meaning,
    required this.forms,
    required this.letterNameArabic,
    required this.exampleArabic,
    required this.exampleTransliteration,
    required this.exampleMeaning,
    required this.note,
  });

  final String id;
  final String type;
  final String arabic;
  final String transliteration;
  final String audioPath;
  final String? meaning;
  final Map<String, String> forms;
  final String? letterNameArabic;
  final String? exampleArabic;
  final String? exampleTransliteration;
  final String? exampleMeaning;
  final String? note;
}
