import Foundation
import UIKit
import ZarliSDKSwift
import ShopifyCheckoutSheetKit

/// A helper class to provide Shopify Checkout support to the Zarli SDK.
public class ZarliShopifyCheckoutHandler: ZarliCheckoutHandler {
    
    /// Shared instance of the handler.
    public static let shared = ZarliShopifyCheckoutHandler()
    
    private init() {}
    
    /// Registers this handler with the Zarli SDK.
    public static func register() {
        ZarliSDK.shared.checkoutHandler = shared
    }
    
    // MARK: - ZarliCheckoutHandler
    
    public func present(checkout: URL, from viewController: UIViewController) {
        print("[ZarliShopifySupport] Presenting Shopify Checkout")
        ShopifyCheckoutSheetKit.present(checkout: checkout, from: viewController)
    }
}
