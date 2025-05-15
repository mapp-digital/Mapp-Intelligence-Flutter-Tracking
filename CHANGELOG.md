## 5.0.8

- Updated native Mapp Intelligence SDK to version 5.1.11
- Added missing methods to disable auto tracking, activity tracking and fragment tracking
  - disableAutoTracking(bool); disableActivityTracking(bool); disableFragmentTracking(bool);
- Fixed bug - setSendAppVersionInEveryRequest not resolved when called with await;
  - issue: https://github.com/mapp-digital/Mapp-Intelligence-Flutter-Tracking/issues/8
- Updated kotlin version: 2.0.20
- Updated android targetSdk to version: 35
- Updated native Mapp Intelligence iOS SDK to version 5.0.15

## 5.0.7

Fixed bug on Android - duplicate records are send for use case when application starts with a optOut=true and some tracking records exists in the local database.

Fix fns feture iOS specific.

**Bug Fixes**

- App first opens were sometimes not tracked correctly.
- Visits were not tracked as expected
- If gallery permission dialog in iOS was used the SDK did not send the first track request.

## 5.0.6

Fixed bug - Fixed unexpected tracking behaviour for media tracking

## 5.0.5

Fixed bug - everId not generated after anonymousTracking set to false
Fixed bug - firstAppOpen parameter not properly calculated

## 5.0.3

Fixed bug to properly show plugin version

## 5.0.2

Added new functionalities to the plugin:
*deeplink tracking
*user matching
Updated internal dependencies.

## 5.0.1

Changed a way how plugin can be initializes for Android. There is no need to initialize plugin from native Java or Kotlin code anymore. This all can be done from the flutter side.

## 5.0.0

First public version

## 0.0.5

Deleted unnecessary setup from the README.md

## 0.0.4

The first version that includes all functions

## 0.0.3

improve description

## 0.0.2

Improve iOS communication

## 0.0.1

initial release.
