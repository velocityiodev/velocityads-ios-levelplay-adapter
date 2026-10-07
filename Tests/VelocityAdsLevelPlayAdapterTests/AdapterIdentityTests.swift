import XCTest

@testable import VelocityAdsLevelPlayAdapter

final class AdapterIdentityTests: XCTestCase {
    func test_registeredObjectiveCClassNames_exist() {
        XCTAssertNotNil(NSClassFromString("VelocityAdsLevelPlayAdapter"))
        XCTAssertNotNil(NSClassFromString("VelocityAdsLevelPlayInterstitial"))
        XCTAssertNotNil(NSClassFromString("VelocityAdsLevelPlayRewarded"))
        XCTAssertNotNil(NSClassFromString("VelocityAdsLevelPlayBanner"))
    }

    func test_adapterVersion_matchesRelease() {
        XCTAssertEqual(velocityAdsLevelPlayAdapterVersion, "0.11.0.0")
        XCTAssertEqual(velocityAdsLevelPlayMediationName, "levelplay")
    }
}
