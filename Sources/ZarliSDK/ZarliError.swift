import Foundation

public enum ZarliError: Error {
    /// The ad request was invalid.
    case invalidRequest
    /// No ad was returned from the server.
    case noFill
    /// The ad failed to load due to a timeout.
    case timeout
    /// An internal error occurred.
    case internalError(String)
}
