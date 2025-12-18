import Foundation
import UIKit

public protocol ZarliInterstitialAdDelegate: AnyObject {
    /// Called when the ad is loaded and ready to be shown.
    func adDidLoad(_ ad: ZarliInterstitialAd)
    /// Called when the ad fails to load.
    func ad(_ ad: ZarliInterstitialAd, didFailToLoad error: Error)
    /// Called when the ad is displayed.
    func adDidShow(_ ad: ZarliInterstitialAd)
    /// Called when the ad is dismissed.
    func adDidDismiss(_ ad: ZarliInterstitialAd)
    /// Called when the user clicks the ad.
    func adDidClick(_ ad: ZarliInterstitialAd)
}

public class ZarliInterstitialAd {
    public weak var delegate: ZarliInterstitialAdDelegate?
    public let adUnitId: String
    
    private var webViewController: ZarliWebViewController?
    // Hardcoded demo URL for now
    private let demoAdURL = URL(string: "https://zarli-ai.github.io/demo-interactive-ads/")!
    
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    public func load() {
        // In a real SDK, we would fetch the ad URL from the server using the adUnitId.
        // For now, we simulate a successful load of the demo URL.
        
        // Simulating network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.delegate?.adDidLoad(self)
        }
    }
    
    public func show(from viewController: UIViewController) {
        let webVC = ZarliWebViewController()
        webVC.delegate = self
        webVC.modalPresentationStyle = .fullScreen
        webVC.load(url: demoAdURL)
        
        self.webViewController = webVC
        
        viewController.present(webVC, animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.adDidShow(self)
        }
    }
}

extension ZarliInterstitialAd: ZarliWebViewControllerDelegate {
    func webViewControllerDidClose(_ controller: ZarliWebViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.adDidDismiss(self)
            self.webViewController = nil
        }
    }
    
    func webViewControllerDidClick(_ controller: ZarliWebViewController) {
        delegate?.adDidClick(self)
    }
}
