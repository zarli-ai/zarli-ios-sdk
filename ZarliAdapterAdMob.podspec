Pod::Spec.new do |s|
  s.name             = 'ZarliAdapterAdMob'
  s.version          = '1.3.25'
  s.summary          = 'AdMob Mediation Adapter for Zarli iOS SDK.'
  s.description      = <<-DESC
    Allows publishers to load Zarli playable ads via Google Mobile Ads (AdMob) Mediation.
                       DESC

  s.homepage         = 'https://github.com/zarli-ai/zarli-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zarli AI' => 'support@zarli.ai' }
  s.source           = { :git => 'https://github.com/zarli-ai/zarli-ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/ZarliAdapterAdMob/**/*.swift'

  s.dependency 'ZarliSDKSwift', '~> 1.3'
  s.dependency 'Google-Mobile-Ads-SDK', '>= 10.0'
  s.static_framework = true
end
