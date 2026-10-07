import IronSource
import VelocityAdsSDK
import XCTest

@testable import VelocityAdsLevelPlayAdapter

final class VelocityAdsErrorMapperTests: XCTestCase {
    func test_map_noFill_usesNoFillType() {
        let result = VelocityAdsErrorMapper.map(
            VelocityAdsError(code: VelocityAdsErrorCode.noFill, message: "No ad")
        )

        XCTAssertEqual(result.type, .noFill)
        XCTAssertEqual(result.code, ISAdapterErrors.internal.rawValue)
        XCTAssertTrue(result.message.contains("\(VelocityAdsErrorCode.noFill)"))
    }

    func test_map_waterfallLoadFailed_isInternalNotNoFill() {
        let result = VelocityAdsErrorMapper.map(
            VelocityAdsError(
                code: VelocityAdsErrorCode.waterfallLoadFailed,
                message: "Winning network failed"
            )
        )

        XCTAssertEqual(result.type, .internal)
        XCTAssertEqual(result.code, ISAdapterErrors.internal.rawValue)
    }

    func test_map_invalidConfiguration_usesMissingParamsCode() {
        for code in [VelocityAdsErrorCode.invalidAppKey, VelocityAdsErrorCode.invalidAdUnitId] {
            let result = VelocityAdsErrorMapper.map(
                VelocityAdsError(code: code, message: "Invalid configuration")
            )
            XCTAssertEqual(result.type, .internal)
            XCTAssertEqual(result.code, ISAdapterErrors.missingParams.rawValue)
        }
    }

    func test_map_adSpent_usesExpiredError() {
        let result = VelocityAdsErrorMapper.map(
            VelocityAdsError(code: VelocityAdsErrorCode.adSpent, message: "Spent")
        )

        XCTAssertEqual(result.type, .adExpired)
        XCTAssertEqual(result.code, ISAdapterErrors.adExpired.rawValue)
    }

    func test_notReady_usesExpiredError() {
        let result = VelocityAdsErrorMapper.notReady()

        XCTAssertEqual(result.type, .adExpired)
        XCTAssertEqual(result.code, ISAdapterErrors.adExpired.rawValue)
    }
}
