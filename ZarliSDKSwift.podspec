Pod::Spec.new do |s|
  s.name             = 'ZarliSDKSwift'
  s.version          = '1.3.57'
  s.summary          = 'The official iOS SDK for the Zarli Ad Network.'
  s.description      = <<-DESC
    ZarliSDKSwift enables mobile publishers to seamlessly integrate high-performance, 
    interactive HTML5 playable ads into their iOS applications to maximize revenue.
                       DESC

  s.homepage         = 'https://github.com/zarli-ai/zarli-ios-sdk'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Zarli AI' => 'founders@zarli.ai' }
  s.source           = { :http => 'https://github.com/zarli-ai/zarli-ios-sdk/releases/download/1.3.57/ZarliSDKSwift.xcframework.zip' }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.vendored_frameworks = 'ZarliSDKSwift.xcframework'
  
  
  # Enable Objective-C interoperability
  s.pod_target_xcconfig = { 
    'SWIFT_OBJC_INTERFACE_HEADER_NAME' => 'ZarliSDKSwift-Swift.h',
    'DEFINES_MODULE' => 'YES'
  }
end
