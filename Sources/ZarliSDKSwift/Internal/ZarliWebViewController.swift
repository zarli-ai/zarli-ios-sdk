import UIKit
import WebKit

protocol ZarliWebViewControllerDelegate: AnyObject {
    func webViewControllerDidClose(_ controller: ZarliWebViewController)
    func webViewControllerDidClick(_ controller: ZarliWebViewController)
}

class ZarliWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    weak var delegate: ZarliWebViewControllerDelegate?
    private var webView: WKWebView!
    
    private var pendingURL: URL?
    private var retryCount: Int = 0
    private let maxRetries: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupCloseButton()
        
        if let url = pendingURL {
            load(url: url)
        }
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        
        // Add message handler to receive messages from the JS ad
        // Usage in JS: window.webkit.messageHandlers.zarli.postMessage("close")
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "zarli")
        config.userContentController = userContentController
        
        config.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.isScrollEnabled = true
        webView.backgroundColor = .black
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView)
    }
    
    private func setupCloseButton() {
        // Fallback native close button (top-right)
        // Ideally the HTML5 ad should provide its own close button that calls the JS message handler
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(white: 0, alpha: 0.5)
        closeButton.layer.cornerRadius = 15
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        closeButton.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)
    }
    
    @objc private func handleCloseButton() {
        delegate?.webViewControllerDidClose(self)
    }
    
    func load(url: URL) {
        if let webView = webView {
            ZarliLogger.debug("WebViewController loading: \(url.absoluteString)")
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            webView.load(request)
        } else {
            pendingURL = url
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        ZarliLogger.error("WebView failed provisional load: \(error.localizedDescription) (Code: \((error as NSError).code))")
        handleLoadError(error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ZarliLogger.error("WebView failed load: \(error.localizedDescription)")
        handleLoadError(error)
    }
    
    private func handleLoadError(_ error: Error) {
        // Check for DNS failure or connection lost
        let code = (error as NSError).code
        if code == -1003 || code == -1001 || code == -1009 { // Host not found, Timeout, or Offline
            if retryCount < maxRetries {
                retryCount += 1
                ZarliLogger.warning("Retrying WebView load (Attempt \(retryCount)/\(maxRetries))...")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self, let url = self.webView.url ?? self.pendingURL else { return }
                    self.load(url: url)
                }
                return
            }
        }
        
        // Critical failure: Close or show error state?
        // For now, we just log. The native close button allows exit.
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "zarli" else { return }
        
        // Handle string messages (legacy)
        if let body = message.body as? String {
            switch body {
            case "close":
                delegate?.webViewControllerDidClose(self)
            case "click":
                delegate?.webViewControllerDidClick(self)
            default:
                break
            }
        }
        // Handle dictionary messages (new format)
        else if let body = message.body as? [String: Any],
                let action = body["action"] as? String {
            switch action {
            case "openURL":
                if let urlString = body["url"] as? String,
                   let url = URL(string: urlString) {
                    // Open URL in Safari
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    ZarliLogger.debug("Opening URL in Safari: \(urlString)")
                }
            default:
                break
            }
        }
    }
}
