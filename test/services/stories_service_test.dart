import 'package:flutter_test/flutter_test.dart';
import 'package:noor/services/stories_service.dart';

void main() {
  group('StoriesService', () {
    final service = StoriesService();

    test(
      'loads bundled categories and stories without a network request',
      () async {
        final data = await service.getStories();
        final categories = service.parseCategories(data['categories'] as List);
        final stories = service.parseStories(data['stories'] as List);

        expect(categories, isNotEmpty);
        expect(stories, isNotEmpty);
        expect(
          stories.every(
            (story) =>
                categories.any((category) => category.id == story.category),
          ),
          isTrue,
        );
      },
    );

    test('rejects malformed story records explicitly', () {
      expect(
        () => service.parseStories([null]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
