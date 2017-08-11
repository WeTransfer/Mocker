//
//  MockingURLProtocol.swift
//  Rabbit
//
//  Created by Antoine van der Lee on 04/05/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import Foundation

/// The protocol which can be used to send Mocked data back. Use the `Mocker` to register `Mock` data
public final class MockingURLProtocol: URLProtocol {
    
    /// Returns Mocked data based on the mocks register in the `Mocker`. Will end up in an error when no Mock data is found for the request.
    public override func startLoading() {
        guard
            let mock = Mocker.mock(for: request),
            let response = HTTPURLResponse(url: mock.url, statusCode: mock.statusCode, httpVersion: Mocker.httpVersion.rawValue, headerFields: mock.headers),
            let data = mock.data(for: request)
        else {
            fatalError("No mocked data found for url \(String(describing: request.url?.absoluteString)) method \(String(describing: request.httpMethod)). Did you forget to use `register()`?")
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    /// Overrides needed to define a valid inheritance of URLProtocol.
    public override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    /// Implementation does nothing, but is needed for a valid inheritance of URLProtocol.
    public override func stopLoading() {
        // No implementation needed
    }
    
    /// Simply sends back the passed request. Implementation is needed for a valid inheritance of URLProtocol.
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}
