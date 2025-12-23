import Foundation

// MARK: - Bid Request

struct BidRequest: Codable {
    let id: String
    let app: AppInfo
    let device: DeviceInfo
    let imp: [Impression]
}

struct AppInfo: Codable {
    let bundle: String
    let ver: String
}

struct DeviceInfo: Codable {
    let ifa: String
    let ua: String
    let ip: String
    let os: String
    let osv: String
    let model: String
    let connection: String
}

struct Impression: Codable {
    let id: String
    let interstitial: Interstitial?
}

struct Interstitial: Codable {}

// MARK: - Bid Response

struct BidResponse: Codable {
    let id: String
    let bidid: String?
    let seatbid: [SeatBid]?
}

struct SeatBid: Codable {
    let bid: [Bid]
}

struct Bid: Codable {
    let id: String?
    let impid: String
    let price: Double
    let adm: String?
    let iurl: String?
    let burl: String?
}
