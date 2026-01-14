Pod::Spec.new do |s|
  s.name             = 'ZarliAdapterAdMob'
  s.version          = '1.3.54'
  s.summary          = 'AdMob Mediation Adapter for Zarli iOS SDK.'
  s.description      = <<-DESC
    Enables publishers to monetize with Zarli playable ads via Google Mobile Ads (AdMob) Mediation.
    Supports interstitial and rewarded ad formats with industry-standard integration.
                       DESC

  s.homepage         = 'https://github.com/zarli-ai/zarli-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zarli AI' => 'founders@zarli.ai' }
  s.source           = { :git => 'https://github.com/zarli-ai/zarli-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/ZarliAdapterAdMob/**/*.{h,m}'
  s.public_header_files = 'Sources/ZarliAdapterAdMob/**/*.h'

  s.dependency 'ZarliSDKSwift', '~> 1.3'
  s.dependency 'Google-Mobile-Ads-SDK', '>= 11.0'
  
  s.static_framework = true
  s.pod_target_xcconfig = { 
    'CLANG_ENABLE_MODULES' => 'YES',
    'GCC_C_LANGUAGE_STANDARD' => 'gnu11'
  }
end
