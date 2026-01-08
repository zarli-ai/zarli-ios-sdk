import Foundation
import GoogleMobileAds
import ZarliSDKSwift

public class ZarliAdMobMediationRewardedAd: NSObject, GoogleMobileAds.MediationRewardedAd {
    
    private let adConfiguration: GoogleMobileAds.MediationRewardedAdConfiguration
    private var completionHandler: GoogleMobileAds.MediationRewardedLoadCompletionHandler?
    private weak var delegate: GoogleMobileAds.MediationRewardedAdEventDelegate?
    private var zarliAd: ZarliRewardedAd?
    
    public init(configuration: GoogleMobileAds.MediationRewardedAdConfiguration, completionHandler: @escaping GoogleMobileAds.MediationRewardedLoadCompletionHandler) {
        self.adConfiguration = configuration
        self.completionHandler = completionHandler
    }
    
    public func loadAd() {
        print("ZarliAdapter: Rewarded loadAd() called")
        var adUnitId = "default-rewarded"
        var explicitBidFloor: Double?
        
        // 1. Parse 'parameter' string (supports JSON or raw string)
        if let parameter = adConfiguration.credentials.settings["parameter"] as? String {
            print("ZarliAdapter: Received parameter: \(parameter)")
            
            var json: [String: Any]?
            if let data = parameter.data(using: .utf8) {
                json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            }
            
            // Fallback: If not valid JSON but contains colons, try wrapping in braces
            if json == nil && parameter.contains(":") {
                let wrapped = "{" + parameter + "}"
                if let data = wrapped.data(using: .utf8) {
                    json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                }
            }

            if let finalJson = json {
                // Handle JSON format
                if let unitId = finalJson["adUnitId"] as? String {
                    adUnitId = unitId
                }
                explicitBidFloor = finalJson["bidFloor"] as? Double
            } else {
                // Fallback: Treat entire string as Ad Unit ID
                adUnitId = parameter
            }
        } else {
            print("ZarliAdapter: No parameter found")
        }
        
        // 2. Determine Bid Floor
        let finalBidFloor: Double
        if let floor = explicitBidFloor {
            finalBidFloor = floor
        } else {
            finalBidFloor = 0.0
        }
        
        print("ZarliAdapter: Using AdUnitID: \(adUnitId), BidFloor: \(finalBidFloor)")
        
        zarliAd = ZarliRewardedAd(adUnitId: adUnitId)
        zarliAd?.bidFloor = finalBidFloor
        zarliAd?.delegate = self
        zarliAd?.load()
    }
    
    public func present(from viewController: UIViewController) {
        if let ad = zarliAd, ad.isReady {
            print("ZarliAdapter: Presenting Ad")
            ad.show(from: viewController)
        } else {
            let error = NSError(domain: "com.zarli.sdk", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ad not ready"])
            print("ZarliAdapter: Failed to present - Ad not ready")
            delegate?.didFailToPresentWithError(error)
        }
    }
}

extension ZarliAdMobMediationRewardedAd: ZarliRewardedAdDelegate {
    public func adDidLoad(_ ad: ZarliRewardedAd) {
        print("ZarliAdapter: adDidLoad - Success")
        delegate = completionHandler?(self, nil)
    }
    
    public func ad(_ ad: ZarliRewardedAd, didFailToLoad error: Error) {
        print("ZarliAdapter: didFailToLoad - Error: \(error.localizedDescription)")
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
        // MediationRewardedAdEventDelegate.didRewardUser() takes no arguments.
        // It relies on the reward configured in the AdMob console.
        delegate?.didRewardUser()
    }
}
