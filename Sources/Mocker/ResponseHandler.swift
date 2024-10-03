//
//  RequestResponseHandler.swift
//
//
//  Created by Tieme on 03/10/2024.
//  Copyright © 2022 WeTransfer. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A handler for a dynamic response
public struct ResponseHandler {

    public typealias OnRequest<HTTPBody> = (_ request: URLRequest, _ httpBody: HTTPBody?) -> (HTTPURLResponse, Data)

    private let internalCallback: (_ request: URLRequest) -> (HTTPURLResponse, Data)

    /// Creates a new request handler using the given `HTTPBody` type, which can be any `Decodable`.
    /// - Parameters:
    ///   - httpBodyType: The decodable type to use for parsing the request body.
    ///   - callback: The callback which will be called just before the request executes.
    public init<HTTPBody: Decodable>(httpBodyType: HTTPBody.Type?, callback: @escaping OnRequest<HTTPBody>) {
        self.init(httpBodyType: httpBodyType, jsonDecoder: JSONDecoder(), callback: callback)
    }

    /// Creates a new request handler using the given `HTTPBody` type, which can be any `Decodable` and decoding it using the provided `JSONDecoder`.
    /// - Parameters:
    ///   - httpBodyType: The decodable type to use for parsing the request body.
    ///   - jsonDecoder: The decoder to use for decoding the request body.
    ///   - callback: The callback which will be called just before the request executes.
    public init<HTTPBody: Decodable>(httpBodyType: HTTPBody.Type?, jsonDecoder: JSONDecoder, callback: @escaping OnRequest<HTTPBody>) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let decodedObject = try? jsonDecoder.decode(HTTPBody.self, from: httpBody)
            else {
                return callback(request, nil)
            }
            return callback(request, decodedObject)
        }
    }

    /// Creates a new request handler using the given callback to call on request without parsing the body arguments.
    /// - Parameter requestCallback: The callback which will be executed just before the request executes, containing the request.
    public init(requestCallback: @escaping (_ request: URLRequest) -> (HTTPURLResponse, Data)) {
        self.internalCallback = requestCallback
    }

    /// Creates a new request handler using the given callback to call on request without parsing the body arguments and without passing the request.
    /// - Parameter callback: The callback which will be executed just before the request executes.
    public init(callback: @escaping () -> (HTTPURLResponse, Data)) {
        self.internalCallback = { _ in
            callback()
        }
    }

    /// Creates a new request handler using the given callback to call on request.
    /// - Parameter jsonDictionaryCallback: The callback that executes just before the request executes, containing the HTTP Body Arguments as a JSON Object Dictionary.
    public init(jsonDictionaryCallback: @escaping ((_ request: URLRequest, _ httpBodyArguments: [String: Any]?) -> (HTTPURLResponse, Data))) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: .fragmentsAllowed) as? [String: Any]
            else {
                return jsonDictionaryCallback(request, nil)
            }
            return jsonDictionaryCallback(request, jsonObject)
        }
    }

    /// Creates a new request handler using the given callback to call on request.
    /// - Parameter jsonDictionaryCallback: The callback that executes just before the request executes, containing the HTTP Body Arguments as a JSON Object Array.
    public init(jsonArrayCallback: @escaping ((_ request: URLRequest, _ httpBodyArguments: [[String: Any]]?) -> (HTTPURLResponse, Data))) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: .fragmentsAllowed) as? [[String: Any]]
            else {
                return jsonArrayCallback(request, nil)
            }
            return jsonArrayCallback(request, jsonObject)
        }
    }

    func handleRequest(_ request: URLRequest) -> (HTTPURLResponse, Data) {
        return internalCallback(request)
    }
}
