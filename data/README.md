# Stories Data - GitHub Hosting

## Setup Instructions:

1. **Upload to GitHub:**
   - Commit `data/stories.json` to your repository
   - Push to GitHub

2. **Update Service URL:**
   - Open `lib/services/stories_service.dart`
   - Replace `YOUR_USERNAME` with your GitHub username:
   ```dart
   static const String githubUrl = 
       'https://raw.githubusercontent.com/YOUR_USERNAME/noor/main/data/stories.json';
   ```

3. **Add More Stories:**
   - Edit `data/stories.json`
   - Add new story objects to the `stories` array
   - Commit and push
   - App will auto-update within 24 hours (or use refresh button)

## JSON Format:

```json
{
  "id": "s6",
  "title": "Story Title",
  "titleUrdu": "کہانی کا عنوان",
  "category": "seerat",
  "content": "English content...",
  "contentUrdu": "اردو مواد...",
  "lesson": "Lesson learned",
  "lessonUrdu": "سبق",
  "tags": ["tag1", "tag2"]
}
```

## Features:

- ✅ Auto-fetch from GitHub
- ✅ 24-hour cache
- ✅ Offline fallback
- ✅ Manual refresh button
- ✅ No app rebuild needed for updates
