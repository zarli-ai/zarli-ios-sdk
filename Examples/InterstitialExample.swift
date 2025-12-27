import UIKit
import ZarliSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load the Interstitial Ad
        // Replace "YOUR_AD_UNIT_ID" with your actual ad unit ID.
        ZarliInterstitialAd.load(adUnitId: "YOUR_AD_UNIT_ID") { [weak self] result in
            switch result {
            case .success(let ad):
                // 2. Ad loaded successfully, show it
                print("Ad Loaded!")
                ad.show(from: self!) {
                    // 3. Ad dismissed callback
                    print("Ad dismissed")
                }
            case .failure(let error):
                // Handle loading error
                print("Ad failed to load: \(error.localizedDescription)")
            }
        }
    }
}
