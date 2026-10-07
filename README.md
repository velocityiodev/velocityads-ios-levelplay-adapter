# VelocityAdsLevelPlayAdapter for iOS

Unity LevelPlay custom-network adapter for the **Velocity Ads iOS SDK**.

## Supported formats

| Format | Supported |
|---|---|
| Interstitial | ✓ |
| Rewarded | ✓ |
| Banner / Large / MREC / Leaderboard / Smart / Custom | ✓ |

## Requirements

| Dependency | Version |
|---|---|
| iOS | 15.0 or later |
| Swift source compatibility | 5.9 or later |
| Unity LevelPlay SDK | 9.6.1 or later, below 10.0 |
| VelocityAdsSDK | 0.11.x |

## Installation

### CocoaPods

```ruby
pod 'IronSourceSDK',                 '>= 9.6.1.0', '< 10.0.0'
pod 'VelocityAdsSDK',                '~> 0.11.0'
pod 'VelocityAdsLevelPlayAdapter',   '0.11.0.0'
```

Then run `pod install`.

### Swift Package Manager

LevelPlay 9.6.1's Swift package requires a Swift 6 toolchain.

1. In Xcode, select **File → Add Package Dependencies**.
2. Enter `https://github.com/velocityiodev/velocityads-ios-levelplay-adapter`.
3. Select **Exact Version** and enter `110000.0.0`.
4. Add `VelocityAdsLevelPlayAdapter` to your application target.
5. Add `-ObjC` under **Other Linker Flags**, as required by LevelPlay.

The adapter uses an encoded three-segment SPM tag because Swift Package Manager
does not accept four-segment versions. Adapter `0.11.0.0` maps to `110000.0.0`.

## LevelPlay setup

Your LevelPlay account must be enabled for custom adapters. Configure the
Velocity Ads network using these Objective-C class names:

| Role | Class |
|---|---|
| Network adapter | `VelocityAdsLevelPlayAdapter` |
| Interstitial | `VelocityAdsLevelPlayInterstitial` |
| Rewarded | `VelocityAdsLevelPlayRewarded` |
| Banner | `VelocityAdsLevelPlayBanner` |

Configure these values for every network instance:

| Key | Value |
|---|---|
| `appKey` | Your Velocity Ads application key |
| `adUnitId` | The Velocity Ads ad unit ID for that LevelPlay instance |

Use one `appKey` per application process. Use a format-appropriate `adUnitId`
for each waterfall instance.

The class names and configuration keys must exactly match the values registered
for the Velocity Ads custom network. The names above are the package defaults;
confirm them against Unity's registration response before release. See
[`REGISTRATION_RENAME_CHECKLIST.md`](REGISTRATION_RENAME_CHECKLIST.md) before
publishing a build that uses different assigned values.

## Privacy

Set privacy through LevelPlay before initialization. LevelPlay forwards the
signals to the adapter, which applies them to Velocity Ads:

| LevelPlay signal | Velocity Ads behavior |
|---|---|
| GDPR consent (`setGDPRConsent`) | Calls `VelocityAds.setConsent(_:)` |
| CCPA opt-out (`setCCPA`) / `do_not_sell` metadata | Calls `VelocityAds.setDoNotSell(_:)` |

The latest received values are re-applied before initialization and ad loads.

## Callback behavior

- A fullscreen Velocity `onAdShown` callback becomes LevelPlay `adDidOpen`.
- A banner Velocity `onAdImpression` callback becomes LevelPlay `adDidOpen`.
- Reward completion becomes LevelPlay `adRewarded`.
- Velocity no-fill errors use LevelPlay's no-fill error type.
- Configuration, expired-ad, and other failures preserve the Velocity error
  code and message while using the closest LevelPlay error category.

## License

Apache License 2.0. See [LICENSE](LICENSE).