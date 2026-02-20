#!/bin/bash

echo "🌙 Setting up Noor App..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

echo "✅ Flutter found"

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Note: Hive adapters already generated manually
echo "✅ Hive adapters ready"

# Generate icons (optional)
echo "🎨 Generating app icons..."
flutter pub run flutter_launcher_icons || echo "⚠️  Icon generation skipped"

# Generate splash screen (optional)
echo "💫 Generating splash screen..."
flutter pub run flutter_native_splash:create || echo "⚠️  Splash generation skipped"

# Download fonts if missing
if [ ! -f "assets/fonts/Amiri-Regular.ttf" ]; then
    echo "📥 Downloading Amiri fonts..."
    mkdir -p assets/fonts
    curl -L -o assets/fonts/Amiri-Regular.ttf https://github.com/alif-type/amiri/raw/main/Amiri-Regular.ttf 2>/dev/null || echo "⚠️  Please download fonts manually from: https://github.com/alif-type/amiri/releases"
    curl -L -o assets/fonts/Amiri-Bold.ttf https://github.com/alif-type/amiri/raw/main/Amiri-Bold.ttf 2>/dev/null
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 To run the app:"
echo "   flutter run"
echo ""
echo "🏗️ To build APK:"
echo "   flutter build apk --release"
echo ""
echo "🌙 بسم اللہ الرحمن الرحیم"
