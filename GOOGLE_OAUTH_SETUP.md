# Google OAuth Setup Guide

## Prerequisites

1. Create a Google Cloud Project at https://console.cloud.google.com
2. Enable Google Sign-In API for your project
3. Create OAuth 2.0 credentials for both iOS and Android

## Backend Configuration

Add these environment variables to your backend `.env` file:

```
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback
```

## iOS Configuration

1. **Add iOS OAuth Client ID**:
   - Go to Google Cloud Console
   - Create iOS OAuth 2.0 Client ID
   - Add your iOS bundle ID (com.jiugames.katomik)

2. **Download Configuration File**:
   - Download `GoogleService-Info.plist`
   - Add it to `/ios/Runner/` in Xcode

3. **Update Info.plist**:
   Add the following to `/ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## Android Configuration

1. **Add Android OAuth Client ID**:
   - Go to Google Cloud Console
   - Create Android OAuth 2.0 Client ID
   - Add your Android package name (com.jiugames.katomik)
   - Add SHA-1 fingerprint (get it with: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`)

2. **Download Configuration File**:
   - Download `google-services.json`
   - Add it to `/android/app/`

3. **Update build.gradle files**:
   
   In `/android/build.gradle`:
   ```gradle
   dependencies {
       // ... existing dependencies
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
   
   In `/android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Flutter Configuration

The Google Sign-In package requires the following setup:

1. **iOS**: The `GoogleService-Info.plist` must be added to the iOS project
2. **Android**: The `google-services.json` must be added to the Android project

## Testing

1. Run the backend with the Google OAuth credentials
2. Run the Flutter app on iOS/Android simulator/device
3. Test the Google Sign-In flow

## Important Notes

- For production, update the callback URL and OAuth credentials
- The SHA-1 fingerprint for Android will be different for release builds
- iOS bundle ID and Android package name must match exactly
- Keep your OAuth client secrets secure and never commit them to version control