import IronSource
import UIKit
import VelocityAdsSDK

/// LevelPlay interstitial ad-unit adapter for Velocity Ads.
///
/// The Objective-C runtime name is part of the LevelPlay registration contract.
@objc(VelocityAdsLevelPlayInterstitial)
public final class VelocityAdsLevelPlayInterstitial: ISBaseInterstitial {
    private var ad: VelocityInterstitialAd?
    private var velocityDelegate: VelocityInterstitialAdapterDelegate?

    public override func loadAd(
        with adData: ISAdData,
        delegate: ISInterstitialAdDelegate
    ) {
        runOnMain { [weak self] in
            self?.loadOnMain(adData: adData, delegate: delegate)
        }
    }

    public override func showAd(
        with viewController: UIViewController,
        adData: ISAdData,
        delegate: ISInterstitialAdDelegate
    ) {
        runOnMain { [weak self] in
            guard let self, let ad = self.ad, ad.isReady else {
                let error = VelocityAdsErrorMapper.notReady()
                delegate.adDidFailToShowWithErrorCode(
                    error.code,
                    errorMessage: error.message
                )
                return
            }
            self.velocityDelegate?.levelPlayDelegate = delegate
            ad.show()
        }
    }

    public override func isAdAvailable(with adData: ISAdData) -> Bool {
        ad?.isReady == true
    }

    public override func destroyAd(with adData: ISAdData) {
        runOnMain { [weak self] in
            self?.ad?.destroy()
            self?.ad = nil
            self?.velocityDelegate = nil
        }
    }

    @MainActor
    private func loadOnMain(
        adData: ISAdData,
        delegate: ISInterstitialAdDelegate
    ) {
        let parameters = VelocityAdsServerParameters(adData: adData)
        guard let appKey = parameters.appKey else {
            failLoad(
                delegate,
                VelocityAdsErrorMapper.missingParameter(
                    VelocityAdsLevelPlayRegistration.appKey
                )
            )
            return
        }
        guard let adUnitId = parameters.adUnitId else {
            failLoad(
                delegate,
                VelocityAdsErrorMapper.missingParameter(
                    VelocityAdsLevelPlayRegistration.adUnitId
                )
            )
            return
        }
        guard let adapter = getNetworkAdapter() as? VelocityAdsLevelPlayAdapter else {
            failLoad(delegate, VelocityAdsErrorMapper.adapterUnavailable())
            return
        }

        adapter.forwardMediationInfo()
        adapter.ensureInitialized(appKey: appKey) { [weak self] outcome in
            guard let self else { return }
            switch outcome {
            case .success:
                self.startLoad(adUnitId: adUnitId, delegate: delegate)
            case let .failure(error):
                self.failLoad(delegate, error)
            }
        }
    }

    @MainActor
    private func startLoad(
        adUnitId: String,
        delegate: ISInterstitialAdDelegate
    ) {
        ad?.destroy()
        let velocityDelegate = VelocityInterstitialAdapterDelegate(delegate: delegate)
        velocityDelegate.onDismissed = { [weak self] in
            self?.ad?.destroy()
            self?.ad = nil
            self?.velocityDelegate = nil
        }
        let request = VelocityInterstitialAdRequest.Builder(adUnitId: adUnitId).build()
        let ad = VelocityInterstitialAd(request)
        self.ad = ad
        self.velocityDelegate = velocityDelegate
        ad.load(delegate: velocityDelegate)
    }

    private func failLoad(
        _ delegate: ISInterstitialAdDelegate,
        _ error: VelocityAdsLevelPlayError
    ) {
        delegate.adDidFailToLoadWithErrorType(
            error.type,
            errorCode: error.code,
            errorMessage: error.message
        )
    }

    private func runOnMain(_ block: @escaping @MainActor () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated(block)
        } else {
            DispatchQueue.main.async {
                MainActor.assumeIsolated(block)
            }
        }
    }
}
