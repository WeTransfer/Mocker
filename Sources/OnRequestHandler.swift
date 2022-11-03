//
//  OnRequestHandler.swift
//  
//
//  Created by Antoine van der Lee on 03/11/2022.
//  Copyright © 2022 WeTransfer. All rights reserved.
//

import Foundation

/// A handler for verifying outgoing requests.
public struct OnRequestHandler {

    public typealias OnRequest<HTTPBody> = (_ request: URLRequest, _ httpBody: HTTPBody?) -> Void

    private let internalCallback: (_ request: URLRequest) -> Void

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
    }

    init(callback: Mock.OnRequest?) {
        self.internalCallback = { request in
            guard
                let httpBody = request.httpBodyStreamData() ?? request.httpBody,
                let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: .fragmentsAllowed) as? [String: Any]
            else {
                callback?(request, nil)
                return
            }
            callback?(request, jsonObject)
        }
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
