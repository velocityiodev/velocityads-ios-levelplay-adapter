import IronSource
import XCTest

@testable import VelocityAdsLevelPlayAdapter

final class VelocityAdsServerParametersTests: XCTestCase {
    func test_readsRegisteredKeysFromLevelPlayAdData() {
        let adData = ISAdData(
            serverData: nil,
            configuration: ["appKey": " app-key "],
            adUnitData: ["adUnitId": " ad-unit "]
        )

        let parameters = VelocityAdsServerParameters(adData: adData)

        XCTAssertEqual(parameters.appKey, "app-key")
        XCTAssertEqual(parameters.adUnitId, "ad-unit")
    }

    func test_values_areTrimmed() {
        let parameters = VelocityAdsServerParameters(
            appKey: " app-key ",
            adUnitId: "\nad-unit\t"
        )

        XCTAssertEqual(parameters.appKey, "app-key")
        XCTAssertEqual(parameters.adUnitId, "ad-unit")
    }

    func test_blankValues_areRejected() {
        let parameters = VelocityAdsServerParameters(appKey: "  ", adUnitId: "\n")

        XCTAssertNil(parameters.appKey)
        XCTAssertNil(parameters.adUnitId)
    }

    func test_registrationKeys_areCentralized() {
        XCTAssertEqual(VelocityAdsLevelPlayRegistration.appKey, "appKey")
        XCTAssertEqual(VelocityAdsLevelPlayRegistration.adUnitId, "adUnitId")
    }
}
