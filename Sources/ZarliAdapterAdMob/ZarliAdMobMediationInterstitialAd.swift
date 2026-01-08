import Foundation
import GoogleMobileAds
import ZarliSDKSwift

public class ZarliAdMobMediationInterstitialAd: NSObject, GoogleMobileAds.MediationInterstitialAd {
    
    private let adConfiguration: GoogleMobileAds.MediationInterstitialAdConfiguration
    private var completionHandler: GoogleMobileAds.MediationInterstitialLoadCompletionHandler?
    private weak var delegate: GoogleMobileAds.MediationInterstitialAdEventDelegate?
    private var zarliAd: ZarliInterstitialAd?
    
    public init(configuration: GoogleMobileAds.MediationInterstitialAdConfiguration, completionHandler: @escaping GoogleMobileAds.MediationInterstitialLoadCompletionHandler) {
        self.adConfiguration = configuration
        self.completionHandler = completionHandler
    }
    
    public func loadAd() {
        print("ZarliAdapter: Interstitial loadAd() called")
        var adUnitId = "default-interstitial"
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
        
        zarliAd = ZarliInterstitialAd(adUnitId: adUnitId)
        zarliAd?.bidFloor = finalBidFloor
        zarliAd?.delegate = self
        zarliAd?.load()
    }
    
    public func present(from viewController: UIViewController) {
        if let ad = zarliAd, ad.isReady {
            ad.show(from: viewController)
        } else {
            // Should not happen if lifecycle is correct
            // But if it does, let the delegate know?
            let error = NSError(domain: "com.zarli.sdk", code: 0, userInfo: [NSLocalizedDescriptionKey: "Ad not ready"])
            delegate?.didFailToPresentWithError(error)
        }
    }
}

extension ZarliAdMobMediationInterstitialAd: ZarliInterstitialAdDelegate {
    public func adDidLoad(_ ad: ZarliInterstitialAd) {
        delegate = completionHandler?(self, nil)
    }
    
    public func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error) {
        _ = completionHandler?(nil, error)
    }
    
    public func adDidShow(_ ad: ZarliInterstitialAd) {
        delegate?.willPresentFullScreenView()
        delegate?.reportImpression()
    }
    
    public func adDidDismiss(_ ad: ZarliInterstitialAd) {
        delegate?.willDismissFullScreenView()
        delegate?.didDismissFullScreenView()
    }
    
    public func adDidClick(_ ad: ZarliInterstitialAd) {
        delegate?.reportClick()
    }
}
