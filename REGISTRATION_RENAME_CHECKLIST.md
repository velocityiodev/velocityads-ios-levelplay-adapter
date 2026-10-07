# LevelPlay registration checklist

Complete this checklist whenever Unity assigns values that differ from the
defaults in this package.

- [ ] Confirm the registered network name.
- [ ] Confirm `VelocityAdsLevelPlayAdapter` as the network adapter class.
- [ ] Confirm `VelocityAdsLevelPlayInterstitial` as the interstitial class.
- [ ] Confirm `VelocityAdsLevelPlayRewarded` as the rewarded class.
- [ ] Confirm `VelocityAdsLevelPlayBanner` as the banner class.
- [ ] Confirm `appKey` as the application-level configuration key.
- [ ] Confirm `adUnitId` as the instance-level configuration key.
- [ ] Update the `@objc(...)` names if any registered class name differs.
- [ ] Update only the constants in `VelocityAdsLevelPlayRegistration.swift` if
      either configuration key differs.
- [ ] Update the class and key tables in `README.md`.
- [ ] Update class-name and configuration-key tests.
- [ ] Verify interstitial, rewarded, and banner requests in LevelPlay's
      Integration Test Suite.

Class names and configuration keys are runtime contracts. Do not publish a
renamed adapter until the LevelPlay registration and documentation match.
