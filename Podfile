platform :ios, '9.0'
inhibit_all_warnings!


target 'PriceWatcher' do
  use_frameworks!
  pod 'Alamofire', '~> 4.4'
  pod 'Fabric', '~> 1.6'
  pod 'Crashlytics', '~> 3.8'
  pod 'SwiftLint', '~> 0.18'
  pod 'SnapKit', '~> 3.2.0'
  pod 'RxSwift',    '~> 3.0'
  pod 'RxCocoa',    '~> 3.0'
  pod 'Moya/RxSwift', '~> 8.0.5'
  pod 'Require', '~> 1.0.1'
  pod 'SDWebImage', '~> 4.0'
  pod 'KeychainAccess', '~> 3.1'
  pod 'Reveal-iOS-SDK', configurations: ['Debug', 'Staging']
  pod 'WaitForIt'

  target 'PriceWatcherTests' do
    inherit! :search_paths
    pod 'Nimble', '~> 7.0'
    pod 'Quick', '~> 1.1'
  end

  target 'PriceWatcherShareExtension' do
    pod 'KeychainAccess', '~> 3.1'
    pod 'SnapKit', '~> 3.2.0'
  end
end

