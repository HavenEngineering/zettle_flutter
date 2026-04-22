## 0.3.1

* Bump Flutter SDK minimum to 3.41.4
* Raise iOS deployment target to 16.0
* Raise Android minSdkVersion to 23
* Migrate example Android build scripts to Kotlin DSL
* Remove duplicate Groovy build scripts from example
* Fail fast with a clear error when GITHUB_TOKEN is missing
* Replace project-specific identifiers in example app config
* Add mounted guards to prevent setState-after-dispose
* Update widget tests for the new example app UI
* Update README prerequisites to match actual minimum versions

## 0.2.15

* Bump Zettle SDK version to 2.42.5
* Fix deprecated APIs in Android plugin (replace `ActivityCompat.startActivityForResult`, remove unsafe `FlutterActivity` cast)
* Fix deprecated APIs and improve safety in iOS plugin (replace deprecated `UIApplication.shared.keyWindow`, remove force unwraps)
* Fix incorrect field labels in refund response `toString()`
* Remove deprecated `package` attribute from AndroidManifest files
* Handle non-OK result codes and Settings task in Android `onActivityResult`
* Include failure reason and error details in payment and refund failed results
* Fix authState observer not registering due to failed `AppCompatActivity` cast
* Remove authState observer on plugin detachment to prevent leaks
* Handle Settings and cancellation flows before null-data guard in `onActivityResult`
* Configure example app via environment variables (no local file edits required)
* Update README testing docs with environment variable setup

## 0.2.12

* Bump zettle SDK version 2.24.2

## 0.2.11

* Bump zettle SDK version 2.6.5

## 0.2.10

* Support flutter SDK version 3.10.1

## 0.2.9

* Fix crash resulted from operating on null refund amount

## 0.2.8

* Add support for specifying refund amount

## 0.2.7

* Introduce session management with login/logout functionalities

## 0.2.6

* Fix failing refund issue resulted from outdated RefundActivity intent builder implementation

## 0.2.5

* Fix payment result amount and instalment mismatch types

## 0.2.4

* SDK update

## 0.2.3

* Expose isInitialized property to check if the SDK is already initialized.

## 0.2.2

* Throw dart exception if already initialised to prevent it being thrown in native code.

## 0.2.1

* Keep the static analyser happy

## 0.2.0

* Gradle updates for github maven authentication
* Update README

## 0.1.1

* Update README

## 0.1.0

* Initial release with Android and iOS support
