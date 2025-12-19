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
    
    private var webViewController: ZarliWebViewController?
    private var bidId: String?
    private var admURL: URL?
    private var billingURL: URL?
    
    // Server Constants
    private let bidEndpoint = "http://us.gamingnow.co:80/bid"
    private let billingEndpointBase = "http://us.gamingnow.co:80/v1/billing"
    
    public init(adUnitId: String) {
        self.adUnitId = adUnitId
    }
    
    public func load() {
        // 1. Construct Bid Request
        let bidRequest = createBidRequest()
        
        // 2. Serialize
        guard let jsonData = try? JSONEncoder().encode(bidRequest) else {
            delegate?.ad(self, didFailToLoad: ZarliError.encodingFailed)
            return
        }
        
        // 3. Send Request
        guard let url = URL(string: bidEndpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("Sending Bid Request to: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.ad(self, didFailToLoad: error)
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.delegate?.ad(self, didFailToLoad: ZarliError.noData)
                }
                return
            }
            
            // 4. Parse Response
            do {
                let bidResponse = try JSONDecoder().decode(BidResponse.self, from: data)
                self.handleBidResponse(bidResponse)
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    self.delegate?.ad(self, didFailToLoad: error)
                }
            }
        }.resume()
    }
    
    private func createBidRequest() -> BidRequest {
        let bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        // Basic Device Info
        let device = UIDevice.current
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let ua = "Mozilla/5.0 (iPhone; CPU iPhone OS \(device.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        
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
            banner: nil, // Interstitial usually doesn't need banner dims or uses full screen, sending interstitial object
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
            DispatchQueue.main.async {
                self.delegate?.ad(self, didFailToLoad: ZarliError.noBid)
            }
            return
        }
        
        self.bidId = response.bidid
        self.admURL = url
        
        // Prefer BURL from response, fallback to manual construction if needed
        if let burlString = bid.burl, let burl = URL(string: burlString) {
             // Fix localhost issue if present in response from server
             if burlString.contains("localhost"), let range = burlString.range(of: "localhost:80") {
                 let fixedString = burlString.replacingCharacters(in: range, with: "us.gamingnow.co:80")
                 self.billingURL = URL(string: fixedString)
             } else {
                 self.billingURL = burl
             }
        } else if let bidId = self.bidId {
             // Manual construction as fallback
             let urlString = "\(billingEndpointBase)?bidid=\(bidId)&win=1"
             self.billingURL = URL(string: urlString)
        }
        
        DispatchQueue.main.async {
            self.delegate?.adDidLoad(self)
        }
    }
    
    public func show(from viewController: UIViewController) {
        guard let admURL = self.admURL else { return }
        
        let webVC = ZarliWebViewController()
        webVC.delegate = self
        webVC.modalPresentationStyle = .fullScreen
        webVC.load(url: admURL)
        
        self.webViewController = webVC
        
        viewController.present(webVC, animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.adDidShow(self)
            self.fireBillingPixel()
        }
    }
    
    private func fireBillingPixel() {
        guard let billingURL = self.billingURL else { return }
        print("Firing Billing Pixel: \(billingURL.absoluteString)")
        URLSession.shared.dataTask(with: billingURL).resume()
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


