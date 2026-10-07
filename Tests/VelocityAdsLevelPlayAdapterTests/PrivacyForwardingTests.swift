import Foundation
import XCTest

@testable import VelocityAdsLevelPlayAdapter

@MainActor
final class PrivacyForwardingTests: XCTestCase {
    override func setUp() {
        super.setUp()
        VelocityAdsLevelPlayAdapter.resetStateForTesting()
    }

    override func tearDown() {
        VelocityAdsLevelPlayAdapter.resetStateForTesting()
        super.tearDown()
    }

    func test_consentAndStringDoNotSell_areRememberedForLoads() {
        let adapter = VelocityAdsLevelPlayAdapter()
        var received: (Bool?, Bool?)?
        VelocityAdsLevelPlayAdapter.privacyForwardingObserverForTesting = {
            received = ($0, $1)
        }

        adapter.setConsent(true)
        adapter.setMetaDataWithKey(
            "do_not_sell",
            andValues: NSMutableArray(object: "yes")
        )
        adapter.forwardPrivacySettings()

        XCTAssertEqual(received?.0, true)
        XCTAssertEqual(received?.1, true)
    }

    func test_numberDoNotSell_isAccepted() {
        let adapter = VelocityAdsLevelPlayAdapter()
        var doNotSell: Bool?
        VelocityAdsLevelPlayAdapter.privacyForwardingObserverForTesting = {
            doNotSell = $1
        }

        adapter.setMetaDataWithKey(
            "do_not_sell",
            andValues: NSMutableArray(object: NSNumber(value: false))
        )
        adapter.forwardPrivacySettings()

        XCTAssertEqual(doNotSell, false)
    }

    func test_unrelatedMetadata_isIgnored() {
        let adapter = VelocityAdsLevelPlayAdapter()
        var doNotSell: Bool?
        VelocityAdsLevelPlayAdapter.privacyForwardingObserverForTesting = {
            doNotSell = $1
        }

        adapter.setMetaDataWithKey(
            "unrelated",
            andValues: NSMutableArray(object: "true")
        )
        adapter.forwardPrivacySettings()

        XCTAssertNil(doNotSell)
    }
}
