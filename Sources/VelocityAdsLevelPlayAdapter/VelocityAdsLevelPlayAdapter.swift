import Foundation
import IronSource
import VelocityAdsSDK

/// Unity LevelPlay custom-network adapter for the Velocity Ads iOS SDK.
///
/// The Objective-C runtime name is part of the LevelPlay registration contract.
@objc(VelocityAdsLevelPlayAdapter)
public final class VelocityAdsLevelPlayAdapter: ISBaseNetworkAdapter, ISAdapterMetaDataProtocol {
    typealias InitOutcome = Result<Void, VelocityAdsLevelPlayError>

    @MainActor
    static let initCoalescer = InitCoalescer<InitOutcome>()

    @MainActor
    private static var activeInitBridge: VelocityAdsInitBridge?

    @MainActor
    private static var consent: Bool?

    @MainActor
    private static var doNotSell: Bool?

    #if DEBUG
    @MainActor
    static var initSDKRunnerForTesting: ((VelocityAdsInitRequest, VelocityAdsInitDelegate) -> Void)?

    @MainActor
    static var privacyForwardingObserverForTesting: ((Bool?, Bool?) -> Void)?

    @MainActor
    static func resetStateForTesting() {
        if initCoalescer.isClaimed {
            initCoalescer.complete(
                with: .failure(
                    VelocityAdsLevelPlayError(
                        type: .internal,
                        code: ISAdapterErrors.internal.rawValue,
                        message: "Test reset"
                    )
                )
            )
        }
        activeInitBridge = nil
        initSDKRunnerForTesting = nil
        privacyForwardingObserverForTesting = nil
        consent = nil
        doNotSell = nil
    }
    #endif

    public override func networkSDKVersion() -> String {
        VelocityAds.getSdkVersion()
    }

    public override func adapterVersion() -> String {
        velocityAdsLevelPlayAdapterVersion
    }

    public override func `init`(
        _ adData: ISAdData,
        delegate: ISNetworkInitializationDelegate
    ) {
        forwardMediationInfo()
        runOnMain { [weak self] in
            guard let self else {
                delegate.onInitDidFailWithErrorCode(
                    ISAdapterErrors.internal.rawValue,
                    errorMessage: "Velocity Ads adapter was released during initialization"
                )
                return
            }
            self.forwardPrivacySettings()
            if VelocityAds.isInitialized() {
                delegate.onInitDidSucceed()
                return
            }

            let parameters = VelocityAdsServerParameters(adData: adData)
            guard let appKey = parameters.appKey else {
                let error = VelocityAdsErrorMapper.missingParameter(
                    VelocityAdsLevelPlayRegistration.appKey
                )
                delegate.onInitDidFailWithErrorCode(error.code, errorMessage: error.message)
                return
            }

            self.ensureInitialized(appKey: appKey) { outcome in
                switch outcome {
                case .success:
                    delegate.onInitDidSucceed()
                case let .failure(error):
                    delegate.onInitDidFailWithErrorCode(
                        error.code,
                        errorMessage: error.message
                    )
                }
            }
        }
    }

    public override func setConsent(_ consent: Bool) {
        runOnMain {
            Self.consent = consent
            VelocityAds.setConsent(consent)
        }
    }

    public func setMetaDataWithKey(
        _ key: String!,
        andValues values: NSMutableArray!
    ) {
        guard let key,
              let values,
              key.caseInsensitiveCompare("do_not_sell") == .orderedSame,
              let value = Self.booleanValue(from: values.firstObject) else {
            return
        }
        runOnMain {
            Self.doNotSell = value
            VelocityAds.setDoNotSell(value)
        }
    }

    @MainActor
    func ensureInitialized(
        appKey: String,
        completion: @escaping @MainActor (InitOutcome) -> Void
    ) {
        forwardPrivacySettings()
        if VelocityAds.isInitialized() {
            completion(.success(()))
            return
        }

        let won = Self.initCoalescer.claim(completion)
        if won {
            startClaimedInit(appKey: appKey)
        }
    }

    @MainActor
    func forwardPrivacySettings() {
        let consent = Self.consent
        let doNotSell = Self.doNotSell
        #if DEBUG
        Self.privacyForwardingObserverForTesting?(consent, doNotSell)
        #endif
        if let consent {
            VelocityAds.setConsent(consent)
        }
        if let doNotSell {
            VelocityAds.setDoNotSell(doNotSell)
        }
    }

    private static let mediationInfoForwardingToken: Void = {
        VelocityAdsMediationBridge.setMediationInfo(
            name: velocityAdsLevelPlayMediationName,
            adapterVersion: velocityAdsLevelPlayAdapterVersion,
            sdkVersion: LevelPlay.sdkVersion()
        )
    }()

    func forwardMediationInfo() {
        _ = Self.mediationInfoForwardingToken
    }

    @MainActor
    private func startClaimedInit(appKey: String) {
        let request = VelocityAdsInitRequest.Builder(appKey).build()
        let bridge = VelocityAdsInitBridge(
            onSuccess: {
                Self.activeInitBridge = nil
                Self.initCoalescer.complete(with: .success(()))
            },
            onFailure: { error in
                Self.activeInitBridge = nil
                if error.code == VelocityAdsErrorCode.sdkInitializationInProgress {
                    InFlightInitPoller.awaitInitialization(
                        isInitialized: { VelocityAds.isInitialized() }
                    ) { initialized in
                        if initialized {
                            Self.initCoalescer.complete(with: .success(()))
                        } else {
                            Self.initCoalescer.complete(
                                with: .failure(
                                    VelocityAdsLevelPlayError(
                                        type: .internal,
                                        code: ISAdapterErrors.internal.rawValue,
                                        message: "Velocity Ads initialization timed out"
                                    )
                                )
                            )
                        }
                    }
                    return
                }
                Self.initCoalescer.complete(with: .failure(VelocityAdsErrorMapper.map(error)))
            }
        )
        Self.activeInitBridge = bridge
        #if DEBUG
        if let runner = Self.initSDKRunnerForTesting {
            runner(request, bridge)
            return
        }
        #endif
        VelocityAds.initSDK(request, delegate: bridge)
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

    private static func booleanValue(from value: Any?) -> Bool? {
        if let number = value as? NSNumber {
            return number.boolValue
        }
        guard let string = value as? String else {
            return nil
        }
        switch string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}

@MainActor
private final class VelocityAdsInitBridge: NSObject, VelocityAdsInitDelegate {
    private let onSuccess: () -> Void
    private let onFailure: (VelocityAdsError) -> Void

    init(onSuccess: @escaping () -> Void, onFailure: @escaping (VelocityAdsError) -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

    func onInitSuccess() {
        onSuccess()
    }

    func onInitFailure(error: VelocityAdsError) {
        onFailure(error)
    }
}
