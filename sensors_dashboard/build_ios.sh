#!/bin/bash

# 🍎 Sensors Dashboard - iOS IPA Builder
# Automatyczne budowanie IPA dla Ad-Hoc distribution

echo "🚀 Building Sensors Dashboard IPA for Ad-Hoc distribution..."
echo ""

# Sprawdź czy jesteśmy w właściwym folderze
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Run this script from sensors_dashboard root directory"
    exit 1
fi

# Pobierz wersję z pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo "📦 Version: $VERSION"
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
cd ios
pod install
cd ..

# Build IPA
echo ""
echo "🔨 Building IPA (this may take 5-10 minutes)..."
flutter build ipa --release

# Sprawdź czy build się powiódł
if [ -f "build/ios/ipa/sensors_dashboard.ipa" ]; then
    echo ""
    echo "✅ SUCCESS! IPA built successfully!"
    echo ""
    echo "📁 Location: build/ios/ipa/sensors_dashboard.ipa"
    echo "📦 Version: $VERSION"
    echo ""
    echo "📤 Next steps:"
    echo "1. Upload to Diawi.com: https://www.diawi.com"
    echo "2. Or use AltStore / Xcode to install"
    echo "3. Share link with testers"
    echo ""
    
    # Otwórz folder z IPA
    open build/ios/ipa/
else
    echo ""
    echo "❌ Build failed. Check errors above."
    echo ""
    echo "Common fixes:"
    echo "- Make sure Xcode is installed"
    echo "- Check signing & provisioning profile in Xcode"
    echo "- Run: open ios/Runner.xcworkspace"
    exit 1
fi
