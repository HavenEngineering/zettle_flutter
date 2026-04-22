# Zettle POS SDK for Flutter

[![pub package](https://img.shields.io/pub/v/zettle.svg)](https://pub.dev/packages/zettle)

A Flutter wrapper for the [Zettle POS SDK](https://developer.zettle.com/) on Android and iOS. Supports card payments, refunds, session management, and card reader settings.

## Prerequisites

1. A [Zettle developer account](https://developer.zettle.com/).
2. iOS 12.0 or higher.
3. Android minSdkVersion 23 or higher.

## Installing

Add zettle to your `pubspec.yaml`:

1) Registered for a Zettle developer account via [Zettle](https://developer.zettle.com/).
2) Deployment Target iOS 16.0 or higher.
3) Android minSdkVersion 23 or higher.

```dart
import 'package:zettle/zettle.dart';
```

## Android setup

Add the Zettle GitHub Packages Maven repository to your **root** `build.gradle` (see [sdk-android](https://github.com/iZettle/sdk-android)):

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://maven.pkg.github.com/iZettle/sdk-android")
            credentials(HttpHeaderCredentials) {
                name "Authorization"
                value "Bearer <YOUR GITHUB TOKEN>"
            }
            authentication {
                header(HttpHeaderAuthentication)
            }
        }
    }
}
```

Add the OAuth callback activity to your `AndroidManifest.xml`:

```xml
<activity
    android:name="com.izettle.android.auth.OAuthActivity"
    android:launchMode="singleTask"
    android:taskAffinity="@string/oauth_activity_task_affinity"
    android:exported="true">
    <intent-filter>
        <data
            android:host="<redirect url host>"
            android:scheme="<redirect url scheme>" />
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
    </intent-filter>
</activity>
```

## iOS setup

Add the following to your `Info.plist` (see [sdk-ios](https://github.com/iZettle/sdk-ios)):

```xml
<key>UISupportedExternalAccessoryProtocols</key>
<array>
    <string>com.izettle.cardreader-one</string>
</array>

<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
    <string>external-accessory</string>
</array>

<key>NSBluetoothAlwaysUsageDescription</key>
<string>Our app uses bluetooth to find, connect and transfer data with Zettle card reader devices.</string>

<key>NSBluetoothPeripheralUsageDescription</key>
<string>Our app uses bluetooth to find, connect and transfer data with Zettle card reader devices.</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string><your OAuth redirect URI scheme></string>
        </array>
    </dict>
</array>

<key>NSLocationWhenInUseUsageDescription</key>
<string>You need to allow this to be able to accept card payments</string>
```

## Usage

### Initialize the SDK

Call `init` once at app startup:

```dart
await Zettle.init(iosClientId, androidClientId, redirectUrl);
```

### Payments

```dart
final response = await Zettle.requestPayment(
  ZettlePaymentRequest(
    amount: 10.00,
    reference: 'unique-reference',
    enableLogin: true,
    enableTipping: false,
    enableInstalments: false,
  ),
);
```

### Refunds

```dart
final response = await Zettle.requestRefund(
  ZettleRefundRequest(reference: 'payment-reference', refundAmount: 10.00),
);
```

### Session management

```dart
await Zettle.login();
await Zettle.logout();
final status = await Zettle.loggedIn();
```

### Card reader settings

```dart
Zettle.showSettings();
```

## Testing locally

To run the example app on a device:

1. **Set your GitHub token** in `example/android/build.gradle.kts` to authenticate with the Zettle Maven repository:
   ```kotlin
   value = "Bearer <YOUR GITHUB TOKEN>"
   ```

2. **Set your application ID** in `example/android/app/build.gradle.kts`:
   ```kotlin
   applicationId = "your.app.id"
   ```

3. **Set your OAuth redirect URL** in `example/android/app/src/main/AndroidManifest.xml`:
   ```xml
   <data
       android:scheme="<your-redirect-scheme>"
       android:host="<your-redirect-host>" />
   ```
   Note: `android:scheme` is the part before `://` and `android:host` is the part after. For example, `myapp://callback` would be `scheme="myapp"` and `host="callback"`.

4. **Set your client IDs and redirect URL** in `example/lib/main.dart` default values, or pass them via `--dart-define`:
   ```bash
   flutter run \
     --dart-define=ZETTLE_IOS_CLIENT_ID=<ios-client-id> \
     --dart-define=ZETTLE_ANDROID_CLIENT_ID=<android-client-id> \
     --dart-define=ZETTLE_REDIRECT_URL=<scheme>://<host>
   ```

5. Run the example app:
   ```bash
   cd example
   flutter run
   ```

## API reference

| Method | Description |
|---|---|
| `Zettle.init(iosClientId, androidClientId, redirectUrl)` | Initialize the SDK (call once) |
| `Zettle.isInitialized` | Whether the SDK has been initialized |
| `Zettle.login()` | Trigger Zettle login |
| `Zettle.logout()` | Log out the current session |
| `Zettle.loggedIn()` | Check login status |
| `Zettle.requestPayment(request)` | Start a card payment |
| `Zettle.requestRefund(request)` | Start a refund |
| `Zettle.showSettings()` | Open card reader settings |
