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

# Generate code
echo "🔨 Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Generate icons (requires icon images)
echo "🎨 Generating app icons..."
flutter pub run flutter_launcher_icons

# Generate splash screen
echo "💫 Generating splash screen..."
flutter pub run flutter_native_splash:create

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

echo ""
echo "✅ Setup complete!"
echo ""
echo "📱 To run the app:"
echo "   flutter run"
echo ""
echo "🏗️ To build APK:"
echo "   flutter build apk --release"
echo ""
echo "🌙 Ramadan Mubarak!"
