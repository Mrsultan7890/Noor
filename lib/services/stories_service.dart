import '../data/stories_data.dart';
import '../models/story_model.dart';

class StoriesService {
  Future<Map<String, dynamic>> getStories() async {
    final categories = storyCategories
        .map<Map<String, dynamic>>(
          (category) => {
            'id': category.id,
            'name': category.name,
            'nameUrdu': category.nameUrdu,
            'icon': category.icon,
            'color': category.color,
            'description': category.description,
          },
        )
        .toList();
    final stories = getAllStories()
        .map<Map<String, dynamic>>(
          (story) => {
            'id': story.id,
            'title': story.title,
            'titleUrdu': story.titleUrdu,
            'category': story.category,
            'content': story.content,
            'contentUrdu': story.contentUrdu,
            'lesson': story.lesson,
            'lessonUrdu': story.lessonUrdu,
            'tags': story.tags,
          },
        )
        .toList();

    return {'categories': categories, 'stories': stories};
  }

  List<StoryCategory> parseCategories(List<dynamic> json) {
    return json.map((category) {
      if (category is! Map<String, dynamic>) {
        throw const FormatException('Invalid story category data.');
      }
      return StoryCategory(
        id: category['id'] as String,
        name: category['name'] as String,
        nameUrdu: category['nameUrdu'] as String,
        icon: category['icon'] as String,
        color: category['color'] as String,
        description: category['description'] as String,
      );
    }).toList();
  }

  List<IslamicStory> parseStories(List<dynamic> json) {
    return json.map((story) {
      if (story is! Map<String, dynamic>) {
        throw const FormatException('Invalid story data.');
      }
      return IslamicStory(
        id: story['id'] as String,
        title: story['title'] as String,
        titleUrdu: story['titleUrdu'] as String,
        category: story['category'] as String,
        content: story['content'] as String,
        contentUrdu: story['contentUrdu'] as String,
        lesson: story['lesson'] as String,
        lessonUrdu: story['lessonUrdu'] as String,
        tags: List<String>.from(story['tags'] as List),
      );
    }).toList();
  }
}
