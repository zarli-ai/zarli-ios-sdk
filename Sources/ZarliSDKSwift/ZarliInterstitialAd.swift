import Foundation
import UIKit
import AdSupport

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
    
    /// Returns true if the ad has been loaded and is ready to show
    public private(set) var isReady: Bool = false
    
    private var webViewController: ZarliWebViewController?
    private var bidId: String?
    private var admURL: URL?
    private var billingURL: URL?
    
    // Server Constants
    private let bidEndpoint = "https://ads-bidding-server-3ul2p3uheq-uc.a.run.app/bid"
    private let billingEndpointBase = "https://ads-bidding-server-3ul2p3uheq-uc.a.run.app/v1/billing"
    
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    public func load() {
        ZarliLogger.debug("Loading ad for Unit ID: \(adUnitId)")
        
        // 1. Fetch User Agent (Async)
        UserAgentFetcher.shared.fetch { [weak self] ua in
            guard let self = self else { return }
            self.performBidRequest(ua: ua)
        }
    }
    
    private func performBidRequest(ua: String) {
        // 2. Construct Bid Request
        let bidRequest = createBidRequest(ua: ua)
        
        // 3. Serialize
        guard let jsonData = try? JSONEncoder().encode(bidRequest) else {
            notifyDelegateDidFail(ZarliError.encodingFailed)
            return
        }
        
        // 4. Send Request
        guard let url = URL(string: bidEndpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        ZarliLogger.debug("Sending Bid Request to: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                ZarliLogger.error("Bid Request failed: \(error.localizedDescription)")
                self.notifyDelegateDidFail(error)
                return
            }
            
            guard let data = data else {
                self.notifyDelegateDidFail(ZarliError.noData)
                return
            }
            
            // 5. Parse Response
            do {
                let bidResponse = try JSONDecoder().decode(BidResponse.self, from: data)
                self.handleBidResponse(bidResponse)
            } catch {
                ZarliLogger.error("Decoding error: \(error.localizedDescription)")
                self.notifyDelegateDidFail(error)
            }
        }.resume()
    }
    
    private func createBidRequest(ua: String) -> BidRequest {
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        // Basic Device Info
        let device = UIDevice.current
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        let deviceInfo = DeviceInfo(
            ifa: idfa,
            ua: ua,
            ip: "", // Server will detect
            os: "iOS",
            osv: device.systemVersion,
            model: device.model,
            connection: "wifi" // simplified
        )
        
        let appInfo = AppInfo(bundle: bundleId, ver: version)
        
        // Need a unique request ID
        let requestId = UUID().uuidString
        
        let imp = Impression(
            id: "1",
            banner: nil,
            interstitial: Interstitial()
        )
        
        return BidRequest(id: requestId, app: appInfo, device: deviceInfo, imp: [imp])
    }
    
    private func handleBidResponse(_ response: BidResponse) {
        // Extract bid
        guard let seatBid = response.seatbid?.first,
              let bid = seatBid.bid.first,
              let adm = bid.adm,
              let url = URL(string: adm) else {
            notifyDelegateDidFail(ZarliError.noBid)
            return
        }
        
        self.bidId = response.bidid
        self.admURL = url
        
        if let burlString = bid.burl, let burl = URL(string: burlString) {
             self.billingURL = burl
        } else if let bidId = self.bidId {
             // Manual construction as fallback
             let urlString = "\(billingEndpointBase)?bidid=\(bidId)&win=1"
             self.billingURL = URL(string: urlString)
        }
        
        DispatchQueue.main.async {
            self.isReady = true
            ZarliLogger.debug("Ad loaded successfully")
            self.delegate?.adDidLoad(self)
        }
    }
    
    /// Shows the interstitial ad. If viewController is not provided, the SDK will attempt to find the top-most controller.
    public func show(from viewController: UIViewController? = nil) {
        // 1. Check readiness
        guard isReady else {
            ZarliLogger.error("Attempted to show ad that is not ready.")
            return
        }
        
        // 2. Check Ad URL
        guard let admURL = self.admURL else {
            ZarliLogger.error("Attempted to show ad but admURL is missing")
            return
        }
        
        // 3. Resolve View Controller
        guard let presenter = viewController ?? UIUtils.getTopViewController() else {
            ZarliLogger.error("Could not find a View Controller to present the ad.")
            return
        }
        
        // 4. Mark as consumed
        self.isReady = false
        
        let webVC = ZarliWebViewController()
        webVC.delegate = self
        webVC.modalPresentationStyle = .fullScreen
        webVC.load(url: admURL)
        
        self.webViewController = webVC
        
        presenter.present(webVC, animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.adDidShow(self)
            self.fireBillingPixel()
        }
    }
    
    private func fireBillingPixel() {
        guard let billingURL = self.billingURL else { return }
        ZarliLogger.debug("Firing Billing Pixel: \(billingURL.absoluteString)")
        URLSession.shared.dataTask(with: billingURL).resume()
    }
    
    private func notifyDelegateDidFail(_ error: Error) {
        DispatchQueue.main.async {
            self.isReady = false
            self.delegate?.ad(self, didFailToLoad: error)
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


