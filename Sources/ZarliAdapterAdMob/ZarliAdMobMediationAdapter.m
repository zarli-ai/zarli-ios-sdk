#import "ZarliAdMobMediationAdapter.h"
#import "ZarliAdMobMediationInterstitialAd.h"
#import "ZarliAdMobMediationRewardedAd.h"
@import ZarliSDKSwift;

@implementation ZarliAdMobMediationAdapter {
  ZarliAdMobMediationInterstitialAd *_interstitialAd;
  ZarliAdMobMediationRewardedAd *_rewardedAd;
}

#pragma mark - GADMediationAdapter Protocol

+ (void)setUpWithConfiguration:(GADMediationServerConfiguration *)configuration
             completionHandler:
                 (GADMediationAdapterSetUpCompletionBlock)completionHandler {
  // Zarli SDK initialization is handled globally via ZarliSDK.shared
  // No additional setup required for the adapter
  completionHandler(nil);
}

+ (GADVersionNumber)adSDKVersion {
  // Return Zarli SDK version
  GADVersionNumber version = {1, 3, 63};
  return version;
}

+ (GADVersionNumber)adapterVersion {
  // Return adapter version
  GADVersionNumber version = {1, 3, 63};
  return version;
}

+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass {
  return nil;
}

#pragma mark - Interstitial Ad Loading

- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
                             (GADMediationInterstitialLoadCompletionHandler)
                                 completionHandler {
  _interstitialAd = [[ZarliAdMobMediationInterstitialAd alloc]
      initWithAdConfiguration:adConfiguration
            completionHandler:completionHandler];
  [_interstitialAd loadAd];
}

#pragma mark - Rewarded Ad Loading

- (instancetype)init {
  self = [super init];
  if (self) {
    NSLog(@"[ZarliAdapter] ZarliAdMobMediationAdapter initialized");
  }
  return self;
}

- (void)loadRewardedAdForAdConfiguration:
            (GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)
                               completionHandler {
  _rewardedAd = [[ZarliAdMobMediationRewardedAd alloc]
      initWithAdConfiguration:adConfiguration
            completionHandler:completionHandler];
  [_rewardedAd loadAd];
}

@end
