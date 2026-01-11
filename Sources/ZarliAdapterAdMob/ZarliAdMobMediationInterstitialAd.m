#import "ZarliAdMobMediationInterstitialAd.h"
@import ZarliSDKSwift;

@interface ZarliAdMobMediationInterstitialAd () <ZarliInterstitialAdDelegate>
@end

@implementation ZarliAdMobMediationInterstitialAd {
  GADMediationInterstitialAdConfiguration *_adConfiguration;
  GADMediationInterstitialLoadCompletionHandler _completionHandler;
  __weak id<GADMediationInterstitialAdEventDelegate> _delegate;
  ZarliInterstitialAd *_zarliAd;
}

- (instancetype)initWithAdConfiguration:
                    (GADMediationInterstitialAdConfiguration *)adConfiguration
                      completionHandler:
                          (GADMediationInterstitialLoadCompletionHandler)
                              completionHandler {
  self = [super init];
  if (self) {
    _adConfiguration = adConfiguration;
    _completionHandler = completionHandler;
  }
  return self;
}

- (void)loadAd {
  NSString *adUnitId = @"default-interstitial";
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

  // Initialize Zarli Interstitial Ad
  _zarliAd = [[ZarliInterstitialAd alloc] initWithAdUnitId:adUnitId];
  _zarliAd.bidFloor = bidFloor;
  _zarliAd.delegate = self;
  [_zarliAd load];
}

#pragma mark - GADMediationInterstitialAd Protocol

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

#pragma mark - ZarliInterstitialAdDelegate

- (void)adDidLoad:(ZarliInterstitialAd *)ad {
  if (_completionHandler) {
    _delegate = _completionHandler(self, nil);
    _completionHandler = nil;
  }
}

- (void)ad:(ZarliInterstitialAd *)ad didFailToLoad:(NSError *)error {
  if (_completionHandler) {
    _completionHandler(nil, error);
    _completionHandler = nil;
  }
}

- (void)adDidShow:(ZarliInterstitialAd *)ad {
  if ([_delegate respondsToSelector:@selector(willPresentFullScreenView)]) {
    [_delegate willPresentFullScreenView];
  }
  if ([_delegate respondsToSelector:@selector(reportImpression)]) {
    [_delegate reportImpression];
  }
}

- (void)adDidDismiss:(ZarliInterstitialAd *)ad {
  if ([_delegate respondsToSelector:@selector(willDismissFullScreenView)]) {
    [_delegate willDismissFullScreenView];
  }
  if ([_delegate respondsToSelector:@selector(didDismissFullScreenView)]) {
    [_delegate didDismissFullScreenView];
  }
}

- (void)adDidClick:(ZarliInterstitialAd *)ad {
  if ([_delegate respondsToSelector:@selector(reportClick)]) {
    [_delegate reportClick];
  }
}

@end
