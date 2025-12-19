import UIKit
import WebKit

protocol ZarliWebViewControllerDelegate: AnyObject {
    func webViewControllerDidClose(_ controller: ZarliWebViewController)
    func webViewControllerDidClick(_ controller: ZarliWebViewController)
}

class ZarliWebViewController: UIViewController, WKScriptMessageHandler {
    weak var delegate: ZarliWebViewControllerDelegate?
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupCloseButton()
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
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        
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
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "zarli" else { return }
        
        if let body = message.body as? String {
            switch body {
            case "close":
                delegate?.webViewControllerDidClose(self)
            case "click":
                delegate?.webViewControllerDidClick(self)
            default:
                print("Unhandled message from ad: \(body)")
            }
        }
    }
}
