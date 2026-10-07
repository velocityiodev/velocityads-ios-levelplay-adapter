import IronSource
import XCTest

@testable import VelocityAdsLevelPlayAdapter

final class BannerSizeResolutionTests: XCTestCase {
    func test_standardSizes_mapToVelocityPresets() {
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(
                ISBannerSize(description: "BANNER", width: 320, height: 50),
                containerWidth: 390
            ),
            .banner
        )
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(
                ISBannerSize(description: "RECTANGLE", width: 300, height: 250),
                containerWidth: 390
            ),
            .mrec
        )
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(
                ISBannerSize(description: "LEADERBOARD", width: 728, height: 90),
                containerWidth: 768
            ),
            .leaderboard
        )
    }

    func test_smart_usesContainerWidth() {
        let smart = ISBannerSize(description: "SMART", width: 0, height: 0)

        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(smart, containerWidth: 390),
            .banner
        )
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(smart, containerWidth: 768),
            .leaderboard
        )
    }

    func test_largeAndCustom_preserveExactDimensions() {
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(
                ISBannerSize(description: "LARGE", width: 320, height: 90),
                containerWidth: 390
            ),
            .custom(width: 320, height: 90)
        )
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(
                ISBannerSize(width: 400, andHeight: 80),
                containerWidth: 400
            ),
            .custom(width: 400, height: 80)
        )
    }

    func test_adaptive_usesRequestedOrContainerWidth() {
        let explicit = ISBannerSize(description: "CUSTOM", width: 400, height: 0)
        explicit.isAdaptive = true
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(explicit, containerWidth: 390),
            .adaptiveBanner(width: 400)
        )

        let fallback = ISBannerSize(description: "SMART", width: 0, height: 0)
        fallback.isAdaptive = true
        XCTAssertEqual(
            VelocityAdsLevelPlayBannerSize.resolve(fallback, containerWidth: 390),
            .adaptiveBanner(width: 390)
        )
    }
}
