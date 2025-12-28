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
        var adUnitId = "default-rewarded"
        var explicitBidFloor: Double?
        
        // 1. Parse 'parameter' string (supports JSON or raw string)
        if let parameter = adConfiguration.credentials.settings["parameter"] as? String {
            if let data = parameter.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                // Handle JSON format
                if let unitId = json["adUnitId"] as? String {
                    adUnitId = unitId
                }
                explicitBidFloor = json["bidFloor"] as? Double
            } else {
                // Fallback: Treat entire string as Ad Unit ID
                adUnitId = parameter
            }
        }
        
        // 2. Determine Bid Floor
        // Priority: Explicit JSON param > AdMob Watermark > Default 0
        let finalBidFloor: Double
        if let floor = explicitBidFloor {
            finalBidFloor = floor
        } else {
             // AdMob passes the floor price in cents (e.g., 1000 = $10.00)
            let floorCents = adConfiguration.watermark?.intValue ?? 0
            finalBidFloor = Double(floorCents) / 100.0
        }
        
        zarliAd = ZarliRewardedAd(adUnitId: adUnitId)
        zarliAd?.bidFloor = finalBidFloor
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
