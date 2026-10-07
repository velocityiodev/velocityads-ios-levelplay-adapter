import IronSource
import VelocityAdsSDK

@MainActor
final class VelocityInterstitialAdapterDelegate: NSObject, VelocityInterstitialAdDelegate {
    weak var levelPlayDelegate: ISInterstitialAdDelegate?
    var onDismissed: (@MainActor () -> Void)?
    private let callbacks: Callbacks?

    struct Callbacks {
        var loaded: () -> Void = {}
        var failedToLoad: (VelocityAdsLevelPlayError) -> Void = { _ in }
        var opened: () -> Void = {}
        var failedToShow: (VelocityAdsLevelPlayError) -> Void = { _ in }
        var clicked: () -> Void = {}
        var closed: () -> Void = {}
    }

    init(delegate: ISInterstitialAdDelegate) {
        levelPlayDelegate = delegate
        callbacks = nil
    }

    init(callbacks: Callbacks) {
        self.callbacks = callbacks
    }

    func onAdLoaded(ad: any VelocityFullscreenAd) {
        if let callbacks {
            callbacks.loaded()
            return
        }
        levelPlayDelegate?.adDidLoad()
    }

    func onAdFailedToLoad(ad: any VelocityFullscreenAd, error: VelocityAdsError) {
        let mapped = VelocityAdsErrorMapper.map(error)
        if let callbacks {
            callbacks.failedToLoad(mapped)
            return
        }
        levelPlayDelegate?.adDidFailToLoad(
            with: mapped.type,
            errorCode: mapped.code,
            errorMessage: mapped.message
        )
    }

    func onAdShown(ad: any VelocityFullscreenAd) {
        if let callbacks {
            callbacks.opened()
            return
        }
        levelPlayDelegate?.adDidOpen()
    }

    func onAdImpression(ad: any VelocityFullscreenAd) {}

    func onAdFailedToShow(ad: any VelocityFullscreenAd, error: VelocityAdsError) {
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

    func onAdClicked(ad: any VelocityFullscreenAd) {
        if let callbacks {
            callbacks.clicked()
            return
        }
        levelPlayDelegate?.adDidClick()
    }

    func onAdDismissed(ad: any VelocityFullscreenAd) {
        if let callbacks {
            callbacks.closed()
            onDismissed?()
            return
        }
        levelPlayDelegate?.adDidClose()
        onDismissed?()
    }
}
