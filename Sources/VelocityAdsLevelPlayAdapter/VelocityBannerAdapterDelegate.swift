import IronSource
import VelocityAdsSDK

@MainActor
final class VelocityBannerAdapterDelegate: NSObject, VelocityBannerAdDelegate {
    private weak var levelPlayDelegate: ISBannerAdDelegate?
    private let adView: VelocityBannerAdView?
    private let callbacks: Callbacks?

    struct Callbacks {
        var loaded: () -> Void = {}
        var failedToLoad: (VelocityAdsLevelPlayError) -> Void = { _ in }
        var opened: () -> Void = {}
        var clicked: () -> Void = {}
        var failedToShow: (VelocityAdsLevelPlayError) -> Void = { _ in }
    }

    init(delegate: ISBannerAdDelegate, adView: VelocityBannerAdView) {
        levelPlayDelegate = delegate
        self.adView = adView
        callbacks = nil
    }

    init(callbacks: Callbacks) {
        self.callbacks = callbacks
        adView = nil
    }

    func onAdLoaded(ad: VelocityBannerAd) {
        if let callbacks {
            callbacks.loaded()
            return
        }
        if let adView {
            levelPlayDelegate?.adDidLoad(with: adView)
        }
    }

    func onAdFailedToLoad(ad: VelocityBannerAd, error: VelocityAdsError) {
        let mapped = VelocityAdsErrorMapper.map(error)
        if let callbacks {
            callbacks.failedToLoad(mapped)
            return
        }
        levelPlayDelegate?.adDidFailToLoadWithErrorType(
            mapped.type,
            errorCode: mapped.code,
            errorMessage: mapped.message
        )
    }

    func onAdImpression(ad: VelocityBannerAd) {
        if let callbacks {
            callbacks.opened()
            return
        }
        levelPlayDelegate?.adDidOpen()
    }

    func onAdClicked(ad: VelocityBannerAd) {
        if let callbacks {
            callbacks.clicked()
            return
        }
        levelPlayDelegate?.adDidClick()
    }

    func onAdFailedToShow(ad: VelocityBannerAd, error: VelocityAdsError) {
        let mapped = VelocityAdsErrorMapper.map(error)
        if let callbacks {
            callbacks.failedToShow(mapped)
            return
        }
        levelPlayDelegate?.adDidFailToShowWithErrorCode(
            mapped.code,
            errorMessage: mapped.message
        )
    }
}
