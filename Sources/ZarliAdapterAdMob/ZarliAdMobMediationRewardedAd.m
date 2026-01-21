#import "ZarliAdMobMediationRewardedAd.h"
@import ZarliSDKSwift;

@interface ZarliAdMobMediationRewardedAd () <ZarliRewardedAdDelegate>
@end

@implementation ZarliAdMobMediationRewardedAd {
  GADMediationRewardedAdConfiguration *_adConfiguration;
  GADMediationRewardedLoadCompletionHandler _completionHandler;
  __weak id<GADMediationRewardedAdEventDelegate> _delegate;
  ZarliRewardedAd *_zarliAd;
}

- (instancetype)initWithAdConfiguration:
                    (GADMediationRewardedAdConfiguration *)adConfiguration
                      completionHandler:
                          (GADMediationRewardedLoadCompletionHandler)
                              completionHandler {
  self = [super init];
  if (self) {
    _adConfiguration = adConfiguration;
    _completionHandler = completionHandler;
  }
  return self;
}

- (void)loadAd {
  NSLog(@"[ZarliAdapter] loadAd called in ZarliAdMobMediationRewardedAd");
  NSString *adUnitId = @"default-rewarded";
  double bidFloor = 0.0;

  // Parse ad unit configuration from AdMob
  id parameterObj = _adConfiguration.credentials.settings[@"parameter"];
  if (parameterObj && [parameterObj isKindOfClass:[NSString class]]) {
    NSString *parameter = (NSString *)parameterObj;
    NSData *data = [parameter dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
      NSError *error = nil;
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                           options:0
                                                             error:&error];
      if (json && [json isKindOfClass:[NSDictionary class]]) {
        if (json[@"adUnitId"]) {
          adUnitId = json[@"adUnitId"];
        }
        if (json[@"bidFloor"]) {
          bidFloor = [json[@"bidFloor"] doubleValue];
        }
      } else {
        // Fallback: treat entire parameter as ad unit ID
        adUnitId = parameter;
      }
    }
  }

  // Initialize Zarli Rewarded Ad
  _zarliAd = [[ZarliRewardedAd alloc] initWithAdUnitId:adUnitId];
  _zarliAd.bidFloor = bidFloor;
  _zarliAd.delegate = self;
  [_zarliAd load];
}

#pragma mark - GADMediationRewardedAd Protocol

- (void)presentFromViewController:(UIViewController *)viewController {
  if (_zarliAd.isReady) {
    [_zarliAd showFrom:viewController];
  } else {
    NSError *error = [NSError
        errorWithDomain:@"com.zarli.adapter"
                   code:0
               userInfo:@{NSLocalizedDescriptionKey : @"Ad not ready"}];
    if ([_delegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
      [_delegate didFailToPresentWithError:error];
    }
  }
}

#pragma mark - ZarliRewardedAdDelegate

- (void)adDidLoad:(ZarliRewardedAd *)ad {
  if (_completionHandler) {
    _delegate = _completionHandler(self, nil);
    _completionHandler = nil;
  }
}

- (void)ad:(ZarliRewardedAd *)ad didFailToLoad:(NSError *)error {
  if (_completionHandler) {
    _completionHandler(nil, error);
    _completionHandler = nil;
  }
}

- (void)adDidShow:(ZarliRewardedAd *)ad {
  if ([_delegate respondsToSelector:@selector(willPresentFullScreenView)]) {
    [_delegate willPresentFullScreenView];
  }
  if ([_delegate respondsToSelector:@selector(didStartVideo)]) {
    [_delegate didStartVideo];
  }
  if ([_delegate respondsToSelector:@selector(reportImpression)]) {
    [_delegate reportImpression];
  }
}

- (void)adDidDismiss:(ZarliRewardedAd *)ad {
  if ([_delegate respondsToSelector:@selector(willDismissFullScreenView)]) {
    [_delegate willDismissFullScreenView];
  }
  if ([_delegate respondsToSelector:@selector(didEndVideo)]) {
    [_delegate didEndVideo];
  }
  if ([_delegate respondsToSelector:@selector(didDismissFullScreenView)]) {
    [_delegate didDismissFullScreenView];
  }
}

- (void)adDidClick:(ZarliRewardedAd *)ad {
  if ([_delegate respondsToSelector:@selector(reportClick)]) {
    [_delegate reportClick];
  }
}

- (void)ad:(ZarliRewardedAd *)ad didEarnReward:(ZarliReward *)reward {
  if ([_delegate respondsToSelector:@selector(didRewardUser)]) {
    [_delegate didRewardUser];
  }
}

@end
