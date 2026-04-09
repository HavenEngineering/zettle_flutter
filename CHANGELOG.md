## 0.2.15

* Bump Zettle SDK version to 2.42.5
* Fix deprecated APIs and update Android build config (compileSdk 36, Java/Kotlin 17, minSdk 24)
* Fix deprecated APIs and improve safety in iOS plugin (replace deprecated `UIApplication.shared.keyWindow`, remove force unwraps)
* Update iOS deployment target to 16.0
* Fix incorrect field labels in refund response `toString()`
* Remove deprecated `package` attribute from AndroidManifest files
* Replace deprecated `ActivityCompat.startActivityForResult` with `Activity.startActivityForResult`
* Update example app with refund support and double-initialisation prevention
* Update README with testing guidelines

## 0.2.14

* Fix Android onActivityResult to handle non-OK result codes instead of silently returning false
* Include failure reason and error details in payment and refund failed results
* Handle unknown/unmatched ZettleResult types with explicit error messages
* Add Settings task handling in onActivityResult

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
