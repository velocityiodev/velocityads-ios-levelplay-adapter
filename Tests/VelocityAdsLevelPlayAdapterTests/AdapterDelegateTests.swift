import IronSource
import VelocityAdsSDK
import XCTest

@testable import VelocityAdsLevelPlayAdapter

@MainActor
final class AdapterDelegateTests: XCTestCase {
    private final class FullscreenAdSpy: VelocityFullscreenAd {
        var isReady = true
        func destroy() {}
    }

    func test_interstitial_translatesLifecycleWithoutDoubleCountingImpression() {
        let ad = FullscreenAdSpy()
        var events: [String] = []
        let delegate = VelocityInterstitialAdapterDelegate(
            callbacks: .init(
                loaded: { events.append("loaded") },
                opened: { events.append("opened") },
                clicked: { events.append("clicked") },
                closed: { events.append("closed") }
            )
        )

        delegate.onAdLoaded(ad: ad)
        delegate.onAdShown(ad: ad)
        delegate.onAdImpression(ad: ad)
        delegate.onAdClicked(ad: ad)
        delegate.onAdDismissed(ad: ad)

        XCTAssertEqual(events, ["loaded", "opened", "clicked", "closed"])
    }

    func test_interstitial_forwardsMappedLoadError() {
        let ad = FullscreenAdSpy()
        var received: VelocityAdsLevelPlayError?
        let delegate = VelocityInterstitialAdapterDelegate(
            callbacks: .init(failedToLoad: { received = $0 })
        )

        delegate.onAdFailedToLoad(
            ad: ad,
            error: VelocityAdsError(code: VelocityAdsErrorCode.noFill, message: "No ad")
        )

        XCTAssertEqual(received?.type, .noFill)
    }

    func test_rewarded_reportsRewardBeforeClose() {
        let ad = FullscreenAdSpy()
        var events: [String] = []
        let delegate = VelocityRewardedAdapterDelegate(
            callbacks: .init(
                opened: { events.append("opened") },
                rewarded: { events.append("rewarded") },
                closed: { events.append("closed") }
            )
        )

        delegate.onAdShown(ad: ad)
        delegate.onUserRewarded(ad: ad)
        delegate.onAdDismissed(ad: ad)

        XCTAssertEqual(events, ["opened", "rewarded", "closed"])
    }

    func test_rewarded_forwardsMappedShowError() {
        let ad = FullscreenAdSpy()
        var received: VelocityAdsLevelPlayError?
        let delegate = VelocityRewardedAdapterDelegate(
            callbacks: .init(failedToShow: { received = $0 })
        )

        delegate.onAdFailedToShow(
            ad: ad,
            error: VelocityAdsError(code: VelocityAdsErrorCode.adSpent, message: "Spent")
        )

        XCTAssertEqual(received?.type, .adExpired)
        XCTAssertEqual(received?.code, ISAdapterErrors.adExpired.rawValue)
    }

    func test_banner_mapsImpressionToOpen() {
        let request = VelocityBannerAdRequest.Builder(
            adUnitId: "test",
            adSize: .banner
        ).build()
        let ad = VelocityBannerAd(request)
        var events: [String] = []
        let delegate = VelocityBannerAdapterDelegate(
            callbacks: .init(
                loaded: { events.append("loaded") },
                opened: { events.append("opened") },
                clicked: { events.append("clicked") }
            )
        )

        delegate.onAdLoaded(ad: ad)
        delegate.onAdImpression(ad: ad)
        delegate.onAdClicked(ad: ad)

        XCTAssertEqual(events, ["loaded", "opened", "clicked"])
        ad.destroy()
    }

    func test_banner_forwardsLoadAndShowErrors() {
        let request = VelocityBannerAdRequest.Builder(
            adUnitId: "test",
            adSize: .banner
        ).build()
        let ad = VelocityBannerAd(request)
        var loadError: VelocityAdsLevelPlayError?
        var showError: VelocityAdsLevelPlayError?
        let delegate = VelocityBannerAdapterDelegate(
            callbacks: .init(
                failedToLoad: { loadError = $0 },
                failedToShow: { showError = $0 }
            )
        )

        delegate.onAdFailedToLoad(
            ad: ad,
            error: VelocityAdsError(code: VelocityAdsErrorCode.noFill, message: "No ad")
        )
        delegate.onAdFailedToShow(
            ad: ad,
            error: VelocityAdsError(code: VelocityAdsErrorCode.internalError, message: "Failed")
        )

        XCTAssertEqual(loadError?.type, .noFill)
        XCTAssertEqual(showError?.type, .internal)
        ad.destroy()
    }
}
