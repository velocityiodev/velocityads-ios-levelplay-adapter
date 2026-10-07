import IronSource
import VelocityAdsSDK

struct VelocityAdsLevelPlayError: Error, Equatable {
    let type: ISAdapterErrorType
    let code: Int
    let message: String
}

enum VelocityAdsErrorMapper {
    static func map(_ error: VelocityAdsError) -> VelocityAdsLevelPlayError {
        let type: ISAdapterErrorType
        let code: Int
        switch error.code {
        case VelocityAdsErrorCode.noFill:
            type = .noFill
            code = ISAdapterErrors.internal.rawValue
        case VelocityAdsErrorCode.invalidAppKey, VelocityAdsErrorCode.invalidAdUnitId:
            type = .internal
            code = ISAdapterErrors.missingParams.rawValue
        case VelocityAdsErrorCode.adSpent:
            type = .adExpired
            code = ISAdapterErrors.adExpired.rawValue
        default:
            type = .internal
            code = ISAdapterErrors.internal.rawValue
        }
        return VelocityAdsLevelPlayError(
            type: type,
            code: code,
            message: "Velocity Ads [\(error.code)]: \(error.message)"
        )
    }

    static func missingParameter(_ key: String) -> VelocityAdsLevelPlayError {
        VelocityAdsLevelPlayError(
            type: .internal,
            code: ISAdapterErrors.missingParams.rawValue,
            message: "Velocity Ads: missing required LevelPlay parameter '\(key)'"
        )
    }

    static func notReady() -> VelocityAdsLevelPlayError {
        VelocityAdsLevelPlayError(
            type: .adExpired,
            code: ISAdapterErrors.adExpired.rawValue,
            message: "Velocity Ads: ad is not ready to show"
        )
    }

    static func adapterUnavailable() -> VelocityAdsLevelPlayError {
        VelocityAdsLevelPlayError(
            type: .internal,
            code: ISAdapterErrors.internal.rawValue,
            message: "Velocity Ads: LevelPlay network adapter is unavailable"
        )
    }
}
