# Engineering guide

## Public repository

This repository is public. Keep source, documentation, workflow text, and
commit messages publisher-safe.

Do not include credentials, private service details, unreleased plans,
maintainer-only release instructions, or non-public SDK implementation details.

## Product

`VelocityAdsLevelPlayAdapter` bridges `VelocityAdsSDK` into Unity LevelPlay's
custom-network waterfall.

- Pod and SPM product: `VelocityAdsLevelPlayAdapter`
- Adapter version: `0.11.0.0`
- Velocity Ads SDK compatibility: `0.11.x`
- LevelPlay compatibility: `>= 9.6.1, < 10.0`
- Minimum iOS: 15.0
- Formats: interstitial, rewarded, and banner

## Runtime class names

LevelPlay discovers these Objective-C runtime classes:

- `VelocityAdsLevelPlayAdapter`
- `VelocityAdsLevelPlayInterstitial`
- `VelocityAdsLevelPlayRewarded`
- `VelocityAdsLevelPlayBanner`

Treat these names as stable integration contracts. Registration-dependent
configuration keys live only in
`Sources/VelocityAdsLevelPlayAdapter/VelocityAdsLevelPlayRegistration.swift`.
Follow `REGISTRATION_RENAME_CHECKLIST.md` if Unity assigns different values.

## Architecture

- `VelocityAdsLevelPlayAdapter` handles initialization, version reporting,
  privacy forwarding, and initialization coalescing.
- One `ISBaseInterstitial`, `ISBaseRewardedVideo`, and `ISBaseBanner` subclass
  owns each LevelPlay ad instance.
- Delegate translators map Velocity callbacks to LevelPlay callbacks.
- `VelocityAdsErrorMapper` preserves Velocity error details while selecting
  LevelPlay's coarse error type and standard error code.
- `VelocityAdsLevelPlayBannerSize` resolves every LevelPlay banner size.

Fullscreen open is reported from Velocity's shown callback. Banner open is
reported from Velocity's measured impression callback. Do not report a second
fullscreen open from the impression callback.

## Versioning

The version source of truth is
`Sources/VelocityAdsLevelPlayAdapter/AdapterVersion.swift`. The podspec must
match it. CocoaPods uses the four-segment tag. SPM uses the encoded tag:
`0.11.0.0` → `110000.0.0`.

## Build and verification

```bash
swift package resolve
xcodebuild test -scheme VelocityAdsLevelPlayAdapter \
  -destination "platform=iOS Simulator,name=iPhone 17"
swiftlint lint --strict
pod lib lint VelocityAdsLevelPlayAdapter.podspec --allow-warnings --skip-tests
```

Before release, verify all registered class names and configuration keys,
run the test suite, lint the source, and test all three formats through
LevelPlay's Integration Test Suite.

## Code rules

- Swift only.
- Keep non-entry-point types internal.
- Do not force unwrap in production code.
- Do not call `fatalError`, `preconditionFailure`, or assertions in production
  adapter code.
- Keep UI work and publisher callbacks on the main actor.
- Do not block threads or add locks.
- Update README and changelog for publisher-visible changes.
