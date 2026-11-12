# 🌙 Noor - Islamic Companion App

**نور - اسلامی ساتھی ایپ**

A beautiful Flutter app for Muslims to maintain their daily Islamic practices.

## ✨ Features

### Core Feature Implementations
1. **Quran Reader** - Complete Quran with Urdu translation
2. **Tasbih Counter** - Digital Dhikr counter with multiple options
3. **Schedule Builder** - Create custom Islamic routines with notifications
4. **Ramadan Planner** - Local Fajr/Maghrib countdowns, available year-round
5. **Dark/Light Theme** - Beautiful Islamic-themed UI
6. **Prayer Tools** - Local prayer times and Qibla direction
7. **Learning & Knowledge** - Hadith, Dua, Names of Allah, stories, and learning guides
8. **Audio Quran** - Recitations with reciter selection, ayah-synced controls, and Android background playback
9. **Kids Zone** - Memory match, prayer quiz, Names puzzle, and Wudu quiz
10. **Book Library** - Search, download, and read Islamic books by category

## 🚀 Getting Started

### Prerequisites
```bash
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0
```

### Quick Setup
```bash
# Clone the repository
git clone https://github.com/yourusername/noor.git
cd noor

# Run setup script (Linux/Mac)
chmod +x setup.sh
./setup.sh

# Or manually:
flutter pub get

# Run the app
flutter run
```

Arabic text uses the bundled Amiri font configured in `pubspec.yaml`.

### Build Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires Mac)
flutter build ios --release
```

## 📱 Screens

- **Home Screen** - Dashboard with all features
- **Quran List** - 114 Surahs
- **Quran Reader** - Arabic + Urdu translation
- **Tasbih Counter** - Interactive counter
- **Schedule List** - View all schedules
- **Schedule Builder** - Create new schedules
- **Ramadan Planner** - Local Fajr/Maghrib countdowns and Hijri date progress
- **Prayer Times** - Location-based daily timings
- **Qibla Direction** - Direction calculated from device location
- **Audio Quran** - Surah playback with multiple reciters
- **Book Library** - Searchable book catalogue, volume downloads, and offline reading
- **Islamic Learning** - Hadith, Dua, stories, and guided lessons
- **Kids Zone** - Memory and quiz games
- **App Settings** - Five selectable gradient themes, light appearance, Arabic text sizing, and daily/prayer reminders

## 🎨 Theme

- Sandalwood: `#2D1B14` → `#4A2E21`
- Olive Branch: `#1A211B` → `#2C352D`
- Emerald Arch: `#0B221B` → `#163D30`
- Rose Marble: `#381F26` → `#542E38`
- Rose Leaves: `#2E1E24` → `#422A33`
- Theme selection is saved and applied to the app background, surfaces, dialogs, popups, and snackbars.

## 📦 Dependencies

- provider - State management
- hive - Local database
- shared_preferences - Settings storage
- flutter_local_notifications - Reminders
- http - API calls
- intl - Date formatting

## 🔧 Configuration

### API Used
- **Quran API**: https://api.alquran.cloud/v1
- Free, unlimited, no API key required
- **Account backend**: `API_BASE_URL` (defaults to `https://noor.bot-keep.xyz`)
- The account backend URL must use HTTPS; local setup guidance is in [TERMUX_SETUP.md](./TERMUX_SETUP.md).

### GitHub-hosted Content Updates

New duas and stories can be published without an app release by editing
[`data/duas.json`](./data/duas.json) or [`data/stories.json`](./data/stories.json)
on GitHub. The app fetches these public JSON files when their screens open,
caches content for offline use, and keeps bundled content as a fallback. See
[`data/README.md`](./data/README.md) for formats and source-review guidance.

The Book Library reads [`data/books.json`](./data/books.json) from GitHub and
also includes that catalogue in the app as an offline fallback. Add a category
and a book entry with its description, author, language, searchable tags,
Internet Archive identifier, and one `volumes` item per PDF. Each volume needs
a number, title, filename, and stable `https://archive.org/download/...` URL.
The app validates these URLs, downloads selected PDFs into its private app
storage, and opens them with an installed PDF reader. Push catalogue changes to
the repository's `main` branch for app users to receive them.

Arabic course JSON and audio are served from jsDelivr at a pinned content
revision, with GitHub Raw as a fallback. Lesson audio is cached on-device after
the first play for faster repeat playback and offline use. Signed-in accounts
sync Arabic lesson completion, points, and daily hearts through Noor's backend.
The pinned course snapshot includes Levels 1–15 and loads through the existing
manifest-driven course screen without requiring bundled lesson assets.

Quran recitation uses an Android media playback service so playback, notification
controls, and lock-screen media controls continue when the app is backgrounded.

### Notifications
- Requires permission on Android/iOS
- Configured in NotificationService

## 🧪 Validation and remaining work

- Prayer-time service unit tests have been added; broader widget and integration coverage is still needed.
- Android/iOS builds and real-device behavior still need verification.
- Prayer calculations currently use a fixed AlAdhan calculation method; add user-selectable calculation settings.
- Cloud backup and a statistics dashboard are not implemented.
- Review privacy policy and app-store release assets before publishing.

## 🤝 Contributing

Contributions welcome! Please read CONTRIBUTING.md

## 📄 License

MIT License

## 🙏 Credits

- Quran.com API
- AlQuran Cloud API
- Flutter community

---

**بسم اللہ الرحمن الرحیم**

May Allah accept this effort. Ameen.
# Noor
