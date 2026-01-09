import Foundation
import GoogleMobileAds
import ZarliSDKSwift

@objc(ZarliAdMobMediationAdapter)
public class ZarliAdMobMediationAdapter: NSObject, MediationAdapter {
    
    // Properties to retain the ads during the loading process
    private var interstitialAd: ZarliAdMobMediationInterstitialAd?
    private var rewardedAd: ZarliAdMobMediationRewardedAd?
    
    public static func adapterVersion() -> VersionNumber {
        let version = VersionNumber(majorVersion: 1, minorVersion: 0, patchVersion: 0)
        return version
    }
    
    public static func adSDKVersion() -> VersionNumber {
        let version = VersionNumber(majorVersion: 1, minorVersion: 0, patchVersion: 0)
        return version
    }
    
    public static func networkExtrasClass() -> AdNetworkExtras.Type? {
        return nil
    }
    
    required public override init() {
        super.init()
    }
    
    public func setUp(with configuration: MediationServerConfiguration, completionHandler: @escaping MediationAdapterSetUpCompletionBlock) {
        
        // In this simple implementation, we assume readiness or successful setup.
        completionHandler(nil)
    }
    
    public func loadInterstitial(for adConfiguration: MediationInterstitialAdConfiguration, completionHandler: @escaping MediationInterstitialLoadCompletionHandler) {
        let ad = ZarliAdMobMediationInterstitialAd(configuration: adConfiguration, completionHandler: completionHandler)
        self.interstitialAd = ad // Retain
        ad.loadAd()
    }
    
    public func loadRewardedAd(for adConfiguration: MediationRewardedAdConfiguration, completionHandler: @escaping MediationRewardedLoadCompletionHandler) {
        let ad = ZarliAdMobMediationRewardedAd(configuration: adConfiguration, completionHandler: completionHandler)
        self.rewardedAd = ad // Retain
        ad.loadAd()
    }
}
