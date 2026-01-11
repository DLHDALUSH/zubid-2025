# Android Studio Setup for ZUBID Flutter App

## Prerequisites

1. **Android Studio** (Latest version recommended)
2. **Flutter SDK** installed at `C:\src\flutter`
3. **Dart Plugin** for Android Studio
4. **Flutter Plugin** for Android Studio

## Opening the Project

1. Open Android Studio
2. Click "Open an Existing Project"
3. Navigate to: `C:\Users\Amer\Desktop\ZUBID\zubid-2025\mobile\flutter_zubid`
4. Click "OK"

## Required Plugins

Make sure these plugins are installed and enabled:
- **Flutter** (includes Dart support)
- **Android** (for Android development)
- **Kotlin** (for Kotlin support)

To install plugins:
1. Go to `File` → `Settings` → `Plugins`
2. Search for and install the required plugins
3. Restart Android Studio

## Project Configuration

The project is now configured with:

### Run Configurations
- **main.dart** - Debug mode with hot reload
- **main.dart (profile mode)** - Performance profiling
- **main.dart (release mode)** - Production build

### Development Features
- Hot reload enabled by default
- Dart analysis configured
- Code formatting on save
- Proper source folders configured
- Build exclusions set up

## Running the App

### Method 1: Using Run Configurations
1. Select device/emulator from the device dropdown
2. Choose run configuration (main.dart for development)
3. Click the green play button or press `Shift + F10`

### Method 2: Using Terminal
```bash
flutter run -d emulator-5554 --hot
```

### Method 3: Using Flutter Commands
- `Ctrl + Shift + P` → "Flutter: Run Flutter App"

## Debugging

1. Set breakpoints by clicking in the gutter
2. Run in debug mode (green bug icon)
3. Use the debugger panel to inspect variables
4. Hot reload: `Ctrl + \` or click the lightning bolt icon

## Useful Shortcuts

- **Hot Reload**: `Ctrl + \`
- **Hot Restart**: `Ctrl + Shift + \`
- **Open Flutter Inspector**: `Ctrl + Shift + I`
- **Format Code**: `Ctrl + Alt + L`
- **Quick Fix**: `Alt + Enter`

## Project Structure

```
lib/
├── main.dart           # App entry point
├── app.dart           # App configuration
├── core/              # Core utilities
├── features/          # Feature modules
└── l10n/             # Localization files
```

## Troubleshooting

### Common Issues

1. **Flutter SDK not found**
   - Go to `File` → `Settings` → `Languages & Frameworks` → `Flutter`
   - Set Flutter SDK path to: `C:\src\flutter`

2. **Device not detected**
   - Run `flutter devices` in terminal
   - Make sure emulator is running
   - Check USB debugging is enabled (for physical devices)

3. **Build errors**
   - Run `flutter clean` then `flutter pub get`
   - Invalidate caches: `File` → `Invalidate Caches and Restart`

### Performance Tips

1. Enable **Dart Analysis** for real-time error checking
2. Use **Flutter Inspector** for widget debugging
3. Enable **Hot Reload** for faster development
4. Use **Profile Mode** for performance testing

## Additional Tools

- **Flutter Inspector**: Widget tree visualization
- **Dart DevTools**: Performance profiling
- **Logcat**: Android system logs
- **Flutter Outline**: Code structure view

## Next Steps

1. Open the project in Android Studio
2. Wait for indexing to complete
3. Select your target device/emulator
4. Run the app using the configured run configuration
5. Start developing with hot reload enabled!
