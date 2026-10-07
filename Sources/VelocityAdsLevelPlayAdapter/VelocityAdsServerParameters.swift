import IronSource

struct VelocityAdsServerParameters: Equatable {
    let appKey: String?
    let adUnitId: String?

    init(adData: ISAdData) {
        appKey = Self.normalized(adData.getString(VelocityAdsLevelPlayRegistration.appKey))
        adUnitId = Self.normalized(adData.getString(VelocityAdsLevelPlayRegistration.adUnitId))
    }

    #if DEBUG
    init(appKey: String?, adUnitId: String?) {
        self.appKey = Self.normalized(appKey)
        self.adUnitId = Self.normalized(adUnitId)
    }
    #endif

    private static func normalized(_ value: String?) -> String? {
        guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }
}
