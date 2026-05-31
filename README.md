# Mobile project — quick run commands

Prerequisites:
- Node.js (>=14)
- npm or yarn
- Java JDK & Android SDK (for Android)
- Xcode (for iOS, macOS only)

1. Install dependencies

```bash
# using npm
npm install

# or using yarn
yarn install
```

2. If this is an Expo project

```bash
# start Metro / Expo dev server
npx expo start

# run on Android device/emulator
npx expo run:android

# run on iOS (macOS only)
npx expo run:ios
```

3. If this is a plain React Native (CLI) project

```bash
# start Metro
npx react-native start

# run on Android (make sure emulator/device is connected)
npx react-native run-android

# run on iOS (macOS only)
npx react-native run-ios
```

4. Troubleshooting

```bash
# clean install
rm -rf node_modules && npm install

# Android gradle clean (Android folder)
cd android && ./gradlew clean && cd ..
```

Replace commands above with your project's specific scripts if package.json defines custom npm scripts.
