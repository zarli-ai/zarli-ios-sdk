# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.2] - 2025-12-24
### Fixed
- Fixed compilation error in `ZarliInterstitialAd.swift` due to missing `rewarded` parameter in `Impression` initialization.

## [1.1.1] - 2025-12-24
### Fixed
- Removed `unsafeFlags` from Package.swift to fix dependency resolution errors in client apps.

## [1.1.0] - 2025-12-24
### Added
- Rewarded Ad support (`ZarliRewardedAd`).
- AdMob Mediation Adapter (`ZarliAdapterAdMob`) for Interstitial and Rewarded ads.

## [1.0.0] - 2025-12-23

### Added
- Initial public release of Zarli iOS SDK.
- Support for interactive HTML5 interstitial ads.
- Automatic User Agent detection and pre-warming.
- Privacy Manifest (`PrivacyInfo.xcprivacy`) for App Store compliance.
- Swift Package Manager support.
