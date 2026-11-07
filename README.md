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
8. **Audio Quran** - Recitations with reciter selection and playback controls
9. **Kids Zone** - Memory match, prayer quiz, Names puzzle, and Wudu quiz

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

### Optional: Add Arabic Fonts
```bash
# Download Amiri fonts from:
# https://github.com/alif-type/amiri/releases
# Place in assets/fonts/ directory
# Then uncomment fonts section in pubspec.yaml
```

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
- **Islamic Learning** - Hadith, Dua, stories, and guided lessons
- **Kids Zone** - Memory and quiz games

## 🎨 Theme

- Primary Color: Green (#2E7D32)
- Secondary Color: Gold (#FFD700)
- Accent Color: Teal (#00897B)
- Dark Mode: Supported

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
- **Account backend**: `API_BASE_URL` (defaults to `https://noor-api.onrender.com`)
- The account backend URL must use HTTPS; local setup guidance is in [TERMUX_SETUP.md](./TERMUX_SETUP.md).

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
