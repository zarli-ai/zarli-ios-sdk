import Foundation
import GoogleMobileAds
import ZarliSDKSwift

public class ZarliAdMobMediationInterstitialAd: NSObject, GADMediationInterstitialAd {
    
    private let adConfiguration: GADMediationInterstitialAdConfiguration
    private var completionHandler: GADMediationInterstitialLoadCompletionHandler?
    private weak var delegate: GADMediationInterstitialAdEventDelegate?
    private var zarliAd: ZarliInterstitialAd?
    
    public init(configuration: GADMediationInterstitialAdConfiguration, completionHandler: @escaping GADMediationInterstitialLoadCompletionHandler) {
        self.adConfiguration = configuration
        self.completionHandler = completionHandler
    }
    
    public func loadAd() {
        let parameter = adConfiguration.credentials.settings["parameter"] as? String
        var adUnitId = parameter ?? "default-interstitial"
        var floorDollars = 0.0

        // Parse JSON parameter if available (e.g., {"adUnitId": "...", "bidFloor": 10.0})
        if let parameter = parameter,
           let data = parameter.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            if let id = json["adUnitId"] as? String {
                adUnitId = id
            }
            if let floor = json["bidFloor"] as? Double {
                floorDollars = floor
            }
        }
        
        zarliAd = ZarliInterstitialAd(adUnitId: adUnitId)
        zarliAd?.bidFloor = floorDollars  // Set the floor from AdMob waterfall
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
