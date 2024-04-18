//
//  URLMatchType.swift
//  Mocker
//
//  Created by Brent Whitman on 2024-04-18.
//

import Foundation

/// How to check if one URL matches another.
public enum URLMatchType {
    /// Matches the full URL, including the query
    case full
    /// Matches the URL excluding the query
    case ignoreQuery
    /// Matches if the URL begins with the prefix
    case prefix
}

extension URL {
    /// Returns the base URL string build with the scheme, host and path. "https://www.wetransfer.com/v1/test?param=test" would be "https://www.wetransfer.com/v1/test".
    var baseString: String? {
        guard let scheme = scheme, let host = host else { return nil }
        return scheme + "://" + host + path
    }
    
    /// Checks if  this URL matches the passed URL using the provided match type.
    ///
    /// - Parameter url: The URL to check for a match.
    /// - Parameter matchType: The approach that will be used to determine whether this URL match the provided URL. Defaults to `full`.
    /// - Returns: `true` if the URL matches based on the match type; `false` otherwise.
    func matches(_ otherURL: URL?, matchType: URLMatchType = .full) -> Bool {
        guard let otherURL else { return false }
        
        switch matchType {
        case .full:
            return absoluteString == otherURL.absoluteString
        case .ignoreQuery:
            return baseString == otherURL.baseString
        case .prefix:
            return absoluteString.hasPrefix(otherURL.absoluteString)
        }
    }
}
