Pod::Spec.new do |s|
  s.name             = 'VelocityAdsLevelPlayAdapter'
  s.version          = '0.11.0.0'
  s.summary          = 'Unity LevelPlay custom adapter for the Velocity Ads iOS SDK.'
  s.description      = <<-DESC
    VelocityAdsLevelPlayAdapter bridges the Velocity Ads iOS SDK into the Unity
    LevelPlay mediation waterfall. It supports interstitial, rewarded, banner,
    large banner, MREC, leaderboard, smart, and custom banner requests.
  DESC

  s.homepage         = 'https://github.com/velocityiodev/velocityads-ios-levelplay-adapter'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Velocity Ads' => 'sdk@velocityads.io' }
  s.source           = {
    :git => 'https://github.com/velocityiodev/velocityads-ios-levelplay-adapter.git',
    :tag => s.version.to_s
  }

  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'
  s.source_files     = 'Sources/VelocityAdsLevelPlayAdapter/**/*.swift'

  s.dependency 'IronSourceSDK', '>= 9.6.1.0', '< 10.0.0'
  s.dependency 'VelocityAdsSDK', '~> 0.11.0'
end
