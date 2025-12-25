import Foundation
import GoogleMobileAds
import ZarliSDKSwift

public class ZarliAdMobMediationRewardedAd: NSObject, GADMediationRewardedAd {
    
    private let adConfiguration: GADMediationRewardedAdConfiguration
    private var completionHandler: GADMediationRewardedLoadCompletionHandler?
    private weak var delegate: GADMediationRewardedAdEventDelegate?
    private var zarliAd: ZarliRewardedAd?
    
    public init(configuration: GADMediationRewardedAdConfiguration, completionHandler: @escaping GADMediationRewardedLoadCompletionHandler) {
        self.adConfiguration = configuration
        self.completionHandler = completionHandler
    }
    
    public func loadAd() {
        let adUnitId = adConfiguration.credentials.settings["parameter"] as? String ?? "default-rewarded"
        
        // Extract bid floor from AdMob watermark
        // AdMob passes the floor price in cents (e.g., 1000 = $10.00)
        let floorCents = adConfiguration.watermark?.intValue ?? 0
        let floorDollars = Double(floorCents) / 100.0
        
        zarliAd = ZarliRewardedAd(adUnitId: adUnitId)
        zarliAd?.bidFloor = floorDollars  // Set the floor from AdMob waterfall
        zarliAd?.delegate = self
        zarliAd?.load()
    }
    
    public func present(from viewController: UIViewController) {
        if let ad = zarliAd, ad.isReady {
            ad.show(from: viewController)
        } else {
            let error = NSError(domain: "com.zarli.sdk", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ad not ready"])
            delegate?.didFailToPresentWithError(error)
        }
    }
}

extension ZarliAdMobMediationRewardedAd: ZarliRewardedAdDelegate {
    public func adDidLoad(_ ad: ZarliRewardedAd) {
        delegate = completionHandler?(self, nil)
    }
    
    public func ad(_ ad: ZarliRewardedAd, didFailToLoad error: Error) {
        _ = completionHandler?(nil, error)
    }
    
    public func adDidShow(_ ad: ZarliRewardedAd) {
        delegate?.willPresentFullScreenView()
        delegate?.didStartVideo()
        delegate?.reportImpression()
    }
    
    public func adDidDismiss(_ ad: ZarliRewardedAd) {
        delegate?.willDismissFullScreenView()
        delegate?.didEndVideo()
        delegate?.didDismissFullScreenView()
    }
    
    public func adDidClick(_ ad: ZarliRewardedAd) {
        delegate?.reportClick()
    }
    
    public func ad(_ ad: ZarliRewardedAd, didEarnReward reward: ZarliReward) {
        let gadReward = GADAdReward(rewardType: reward.type, rewardAmount: NSDecimalNumber(value: reward.amount))
        delegate?.didRewardUser(with: gadReward)
    }
}
