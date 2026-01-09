# 🍎 Sensors Dashboard - iOS IPA Builder (PowerShell)
# Automatyczne budowanie IPA dla Ad-Hoc distribution

Write-Host "🚀 Building Sensors Dashboard IPA for Ad-Hoc distribution..." -ForegroundColor Green
Write-Host ""

# Sprawdź czy jesteśmy w właściwym folderze
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Run this script from sensors_dashboard root directory" -ForegroundColor Red
    exit 1
}

# Pobierz wersję z pubspec.yaml
$VERSION = (Select-String -Path "pubspec.yaml" -Pattern "^version:").Line -replace "version: ", ""
Write-Host "📦 Version: $VERSION" -ForegroundColor Cyan
Write-Host ""

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Dla Windows nie budujemy iOS (wymaga Mac)
Write-Host ""
Write-Host "⚠️  iOS build requires macOS with Xcode installed" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 To build IPA on Mac, run:" -ForegroundColor Cyan
Write-Host "   flutter build ipa --release" -ForegroundColor White
Write-Host ""
Write-Host "Or use the build_ios.sh script on Mac:" -ForegroundColor Cyan
Write-Host "   chmod +x build_ios.sh" -ForegroundColor White
Write-Host "   ./build_ios.sh" -ForegroundColor White
Write-Host ""
Write-Host "For Windows, you can build Android APK instead:" -ForegroundColor Cyan
Write-Host "   flutter build apk --release" -ForegroundColor White
Write-Host ""
