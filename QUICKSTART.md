# Quick Start Guide

## First-Time Setup

After cloning or pulling the latest changes, follow these steps:

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Drift Database Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `lib/database/drift_database.g.dart`.

### 3. Run the Application

#### For Web (Chrome):
```bash
flutter run -d chrome
```

#### For Web (Server mode - best for testing):
```bash
flutter run -d web-server --web-port=8080
```
Then open http://localhost:8080 in your browser.

#### For Android:
```bash
flutter run -d android
```

#### For iOS:
```bash
flutter run -d ios
```

## Default Login Credentials

The app automatically creates default users on first run:

**Admin Account:**
- Username: `admin`
- Password: `admin123`

**Cashier Account:**
- Username: `cashier`
- Password: `cashier123`

## Common Issues & Solutions

### Issue: "Cannot find drift_database.g.dart"
**Solution:** Run the build_runner command:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Build runner conflicts
**Solution:** Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Web app doesn't load
**Solution:**
1. Clear browser cache
2. Try a different browser
3. Use `--web-renderer html` flag:
```bash
flutter run -d chrome --web-renderer html
```

### Issue: Changes not reflected
**Solution:**
If you modified database tables:
1. Update `schemaVersion` in `lib/database/drift_database.dart`
2. Regenerate code: `flutter pub run build_runner build --delete-conflicting-outputs`

## Database Storage Locations

### Web Platform
- Uses IndexedDB in the browser
- Database name: `retail_management_db`
- To inspect: Open Browser DevTools → Application → IndexedDB

### Mobile Platforms
- Android: `/data/data/com.yourcompany.retail_management/databases/retail_management.db`
- iOS: Application Documents Directory

### Desktop Platforms
- Database stored in application documents directory
- Location varies by OS (Windows/macOS/Linux)

## Hot Reload & Hot Restart

- **Hot Reload** (`r`): Quick code changes without restarting
- **Hot Restart** (`R`): Full restart, useful for state management changes
- **Full Restart**: Stop and run again if database schema changed

## Building for Production

### Web
```bash
flutter build web --release
```
Output: `build/web/`

For better performance, choose a renderer:
```bash
# Smaller size, works everywhere
flutter build web --web-renderer html

# Better graphics, larger size
flutter build web --web-renderer canvaskit

# Auto-detect (recommended)
flutter build web --web-renderer auto
```

### Android
```bash
# APK (for testing)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Development Tips

### Watch Mode (Auto-rebuild on changes)
```bash
flutter pub run build_runner watch
```

This automatically regenerates code when you modify database tables.

### Analyzing Code
```bash
flutter analyze
```

### Running Tests
```bash
flutter test
```

## Platform-Specific Features

### Web
- ✅ Full database support via IndexedDB
- ✅ All CRUD operations work
- ⚠️  File operations limited (logo upload may need adjustment)
- ⚠️  Printing uses browser print dialog

### Mobile
- ✅ Full native database support
- ✅ All features working
- ✅ Camera/file access for logo upload
- ✅ Native printing support

## Performance Optimization

### For Web
1. Use release mode: `flutter run -d chrome --release`
2. Enable tree shaking (automatic in release mode)
3. Consider PWA for offline support

### For Mobile
1. Use release mode: `flutter build apk --release`
2. Enable R8/ProGuard (Android)
3. Optimize images in assets

## Need Help?

1. Check `MIGRATION.md` for detailed migration info
2. Review Drift documentation: https://drift.simonbinder.eu/
3. Check Flutter Web docs: https://docs.flutter.dev/platform-integration/web

---

**Happy Coding! 🚀**
