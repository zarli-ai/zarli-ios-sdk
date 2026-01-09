#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

/// Zarli Rewarded Ad Adapter for AdMob Mediation
@interface ZarliAdMobMediationRewardedAd : NSObject <GADMediationRewardedAd>

- (instancetype)initWithAdConfiguration:
                    (GADMediationRewardedAdConfiguration *)adConfiguration
                      completionHandler:
                          (GADMediationRewardedLoadCompletionHandler)
                              completionHandler;

- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
