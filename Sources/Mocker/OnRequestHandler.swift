//
//  OnRequestHandler.swift
//  
//
//  Created by Antoine van der Lee on 03/11/2022.
//  Copyright © 2022 WeTransfer. All rights reserved.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A handler for verifying outgoing requests.
public struct OnRequestHandler {

    public typealias OnRequest<HTTPBody> = (_ request: URLRequest, _ httpBody: HTTPBody?) -> Void

    private let internalCallback: (_ request: URLRequest) -> Void
    let legacyCallback: Mock.OnRequest?

    /// Creates a new request handler using the given `HTTPBody` type, which can be any `Decodable`.
    /// - Parameters:
    ///   - httpBodyType: The decodable type to use for parsing the request body.
    ///   - callback: The callback which will be called just before the request executes.
    public init<HTTPBody: Decodable>(httpBodyType: HTTPBody.Type?, callback: @escaping OnRequest<HTTPBody>) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let decodedObject = try? JSONDecoder().decode(HTTPBody.self, from: httpBody)
            else {
                callback(request, nil)
                return
            }
            callback(request, decodedObject)
        }
        legacyCallback = nil
    }

    /// Creates a new request handler using the given callback to call on request without parsing the body arguments.
    /// - Parameter requestCallback: The callback which will be executed just before the request executes, containing the request.
    public init(requestCallback: @escaping (_ request: URLRequest) -> Void) {
        self.internalCallback = requestCallback
        legacyCallback = nil
    }

    /// Creates a new request handler using the given callback to call on request without parsing the body arguments and without passing the request.
    /// - Parameter callback: The callback which will be executed just before the request executes.
    public init(callback: @escaping () -> Void) {
        self.internalCallback = { _ in
            callback()
        }
        legacyCallback = nil
    }

    /// Creates a new request handler using the given callback to call on request.
    /// - Parameter jsonDictionaryCallback: The callback that executes just before the request executes, containing the HTTP Body Arguments as a JSON Object Dictionary.
    public init(jsonDictionaryCallback: @escaping ((_ request: URLRequest, _ httpBodyArguments: [String: Any]?) -> Void)) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: .fragmentsAllowed) as? [String: Any]
            else {
                jsonDictionaryCallback(request, nil)
                return
            }
            jsonDictionaryCallback(request, jsonObject)
        }
        self.legacyCallback = nil
    }

    /// Creates a new request handler using the given callback to call on request.
    /// - Parameter jsonDictionaryCallback: The callback that executes just before the request executes, containing the HTTP Body Arguments as a JSON Object Array.
    public init(jsonArrayCallback: @escaping ((_ request: URLRequest, _ httpBodyArguments: [[String: Any]]?) -> Void)) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: .fragmentsAllowed) as? [[String: Any]]
            else {
                jsonArrayCallback(request, nil)
                return
            }
            jsonArrayCallback(request, jsonObject)
        }
        self.legacyCallback = nil
    }

    init(legacyCallback: Mock.OnRequest?) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: .fragmentsAllowed) as? [String: Any]
            else {
                legacyCallback?(request, nil)
                return
            }
            legacyCallback?(request, jsonObject)
        }
        self.legacyCallback = legacyCallback
    }

    func handleRequest(_ request: URLRequest) {
        internalCallback(request)
    }
}

private extension URLRequest {
    /// We need to use the http body stream data as the URLRequest once launched converts the `httpBody` to this stream of data.
    func httpBodyStreamData() -> Data? {
        guard let bodyStream = self.httpBodyStream else { return nil }

        bodyStream.open()

        // Will read 16 chars per iteration. Can use bigger buffer if needed
        let bufferSize: Int = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()

        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readData)
        }

        buffer.deallocate()
        bodyStream.close()

        return data
    }
}
