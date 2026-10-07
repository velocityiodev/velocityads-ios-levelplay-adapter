import CoreGraphics
import IronSource
import VelocityAdsSDK

enum VelocityAdsLevelPlayBannerSize {
    static func resolve(_ size: ISBannerSize, containerWidth: CGFloat) -> VelocityBannerAdSize {
        let width = CGFloat(size.width)
        let height = CGFloat(size.height)

        if size.isAdaptive {
            return .adaptiveBanner(width: width > 0 ? width : containerWidth)
        }

        switch size.sizeDescription.uppercased() {
        case "BANNER":
            return .banner
        case "RECTANGLE":
            return .mrec
        case "LEADERBOARD":
            return .leaderboard
        case "SMART":
            return containerWidth >= 728 ? .leaderboard : .banner
        case "LARGE":
            return .custom(width: 320, height: 90)
        case "CUSTOM":
            return .custom(width: width, height: height)
        default:
            if width > 0, height > 0 {
                return .custom(width: width, height: height)
            }
            return .banner
        }
    }
}
