import IronSource
import UIKit
import VelocityAdsSDK

/// LevelPlay banner ad-unit adapter for Velocity Ads.
///
/// The Objective-C runtime name is part of the LevelPlay registration contract.
@objc(VelocityAdsLevelPlayBanner)
public final class VelocityAdsLevelPlayBanner: ISBaseBanner {
    private var ad: VelocityBannerAd?
    private var adView: VelocityBannerAdView?
    private var velocityDelegate: VelocityBannerAdapterDelegate?

    public override func loadAd(
        with adData: ISAdData,
        viewController: UIViewController,
        size: ISBannerSize,
        delegate: ISBannerAdDelegate
    ) {
        runOnMain { [weak self] in
            guard let self else { return }
            let parameters = VelocityAdsServerParameters(adData: adData)
            guard let appKey = parameters.appKey else {
                self.failLoad(
                    delegate,
                    VelocityAdsErrorMapper.missingParameter(
                        VelocityAdsLevelPlayRegistration.appKey
                    )
                )
                return
            }
            guard let adUnitId = parameters.adUnitId else {
                self.failLoad(
                    delegate,
                    VelocityAdsErrorMapper.missingParameter(
                        VelocityAdsLevelPlayRegistration.adUnitId
                    )
                )
                return
            }
            guard let adapter = self.getNetworkAdapter() as? VelocityAdsLevelPlayAdapter else {
                self.failLoad(
                    delegate,
                    VelocityAdsLevelPlayError(
                        type: .internal,
                        code: ISAdapterErrors.internal.rawValue,
                        message: "Velocity Ads: LevelPlay network adapter is unavailable"
                    )
                )
                return
            }

            adapter.forwardMediationInfo()
            adapter.ensureInitialized(appKey: appKey) { [weak self] outcome in
                guard let self else { return }
                switch outcome {
                case .success:
                    self.ad?.destroy()
                    let resolvedSize = VelocityAdsLevelPlayBannerSize.resolve(
                        size,
                        containerWidth: viewController.view.bounds.width
                    )
                    let adView = VelocityBannerAdView()
                    let velocityDelegate = VelocityBannerAdapterDelegate(
                        delegate: delegate,
                        adView: adView
                    )
                    let request = VelocityBannerAdRequest.Builder(
                        adUnitId: adUnitId,
                        adSize: resolvedSize
                    ).build()
                    let ad = VelocityBannerAd(request)
                    self.ad = ad
                    self.adView = adView
                    self.velocityDelegate = velocityDelegate
                    ad.load(bannerView: adView, delegate: velocityDelegate)
                case let .failure(error):
                    self.failLoad(delegate, error)
                }
            }
        }
    }

    public override func destroyAd(with adData: ISAdData) {
        runOnMain { [weak self] in
            self?.ad?.destroy()
            self?.ad = nil
            self?.adView = nil
            self?.velocityDelegate = nil
        }
    }

    public override func isSupportAdaptiveBanner() -> Bool {
        true
    }

    private func failLoad(
        _ delegate: ISBannerAdDelegate,
        _ error: VelocityAdsLevelPlayError
    ) {
        delegate.adDidFailToLoad(
            with: error.type,
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
