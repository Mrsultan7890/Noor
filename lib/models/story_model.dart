class IslamicStory {
  final String id;
  final String title;
  final String titleUrdu;
  final String category;
  final String content;
  final String contentUrdu;
  final String lesson;
  final String lessonUrdu;
  final List<String> tags;

  IslamicStory({
    required this.id,
    required this.title,
    required this.titleUrdu,
    required this.category,
    required this.content,
    required this.contentUrdu,
    required this.lesson,
    required this.lessonUrdu,
    required this.tags,
  });
}

class StoryCategory {
  final String id;
  final String name;
  final String nameUrdu;
  final String icon;
  final String color;
  final String description;

  StoryCategory({
    required this.id,
    required this.name,
    required this.nameUrdu,
    required this.icon,
    required this.color,
    required this.description,
  });
}
