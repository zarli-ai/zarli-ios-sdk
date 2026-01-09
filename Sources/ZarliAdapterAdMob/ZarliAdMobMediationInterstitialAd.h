#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

/// Zarli Interstitial Ad Adapter for AdMob Mediation
@interface ZarliAdMobMediationInterstitialAd
    : NSObject <GADMediationInterstitialAd>

- (instancetype)initWithAdConfiguration:
                    (GADMediationInterstitialAdConfiguration *)adConfiguration
                      completionHandler:
                          (GADMediationInterstitialLoadCompletionHandler)
                              completionHandler;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
