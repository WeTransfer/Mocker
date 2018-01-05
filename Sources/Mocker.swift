//
//  Mocker.swift
//  Rabbit
//
//  Created by Antoine van der Lee on 04/05/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import Foundation

/// Can be used for registering Mocked data, returned by the `MockingURLProtocol`.
public struct Mocker {
    
    internal enum HTTPVersion: String {
        case http1_0 = "HTTP/1.0"
        case http1_1 = "HTTP/1.1"
        case http2_0 = "HTTP/2.0"
    }
    
    /// The shared instance of the Mocker, can be used to register and return mocks.
    private static var shared = Mocker()
    
    /// The HTTP Version to use in the mocked response.
    internal static var httpVersion: HTTPVersion = HTTPVersion.http1_1
    
    /// The registrated mocks.
    private var mocks: [Mock] = []
    
    /// URLs to ignore for mocking.
    private var ignoredURLs: [URL] = []
    
    private init() {
        // Whenever someone is requesting the Mocker, we want the URL protocol to be activated.
        URLProtocol.registerClass(MockingURLProtocol.self)
    }
    
    /// Register new Mocked data. If a mock for the same URL and HTTPMethod exists, it will be overwritten.
    ///
    /// - Parameter mock: The Mock to be registered for future requests.
    public static func register(_ mock: Mock) {
        if let existingIndex = shared.mocks.index(of: mock) {
            /// Delete the existing mock.
            shared.mocks.remove(at: existingIndex)
        }
        shared.mocks.append(mock)
    }
    
    public static func addMocksTo(launchEnvironments: inout [String: String]) {
        let encoder = JSONEncoder()
        
        let jsonMocks = shared.mocks.flatMap { (mock) -> Data? in
            return try? encoder.encode(mock)
        }.flatMap { (data) -> String? in
            return String(data: data, encoding: .utf8)
        }.joined(separator: ",")
        
        launchEnvironments["mocks"] = jsonMocks
    }
    
    /// Register an URL to ignore for mocking. This will let the URL work as if the Mocker doesn't exist.
    ///
    /// - Parameter url: The URL to mock.
    public static func ignore(_ url: URL) {
        shared.ignoredURLs.append(url)
    }
    
    /// Checks if the passed URL should be handled by the Mocker. If the URL is registered to be ignored, it will not handle the URL.
    ///
    /// - Parameter url: The URL to check for.
    /// - Returns: `true` if it should be mocked, `false` if the URL is registered as ignored.
    public static func shouldHandle(_ url: URL) -> Bool {
        return !shared.ignoredURLs.contains(url)
    }
    
    /// Retrieve a Mock for the given request. Matches on `request.url` and `request.httpMethod`.
    ///
    /// - Parameter request: The request to search for a mock.
    /// - Returns: A mock if found, `nil` if there's no mocked data registered for the given request.
    static func mock(for request: URLRequest) -> Mock? {
        return shared.mocks.first(where: { $0 == request })
    }
}
