//
//  Mock.swift
//  Rabbit
//
//  Created by Antoine van der Lee on 04/05/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//
//  Mocker is only used for tests. In tests we don't even check on this SwiftLint warning, but Mocker is available through Rabbit for usage out of Rabbit. Disable for this case.
//  swiftlint:disable force_unwrapping

import Foundation
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A Mock which can be used for mocking data requests with the `Mocker` by calling `Mocker.register(...)`.
public struct Mock: Equatable {

    /// HTTP method definitions.
    ///
    /// See https://tools.ietf.org/html/rfc7231#section-4.3
    public enum HTTPMethod: String, Sendable {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }

    public typealias OnRequest = (_ request: URLRequest, _ httpBodyArguments: [String: Any]?) -> Void

    /// The type of the data which designates the Content-Type header.
    @available(*, deprecated, message: "Calling this property is unsafe after migrating to the `contentType` initializers, and will be removed in an upcoming release. Use `contentType` instead.")
    public var dataType: DataType {
        return contentType!
    }
    
    /// The type of the data which designates the Content-Type header. If set to `nil`, no Content-Type header is added to the headers.
    public let contentType: DataType?

    /// If set, the error that URLProtocol will report as a result rather than returning data from the mock
    public let requestError: Error?

    /// The headers to send back with the response.
    public let headers: [String: String]

    /// The HTTP status code to return with the response.
    public let statusCode: Int

    /// The URL value generated based on the Mock data. Force unwrapped on purpose. If you access this URL while it's not set, this is a programming error.
    public var url: URL {
        if urlToMock == nil && !data.keys.contains(.get) {
            assertionFailure("For non GET mocks you should use the `request` property so the HTTP method is set.")
        }
        return urlToMock ?? generatedURL
    }

    /// The URL to mock as set implicitely from the init.
    private let urlToMock: URL?

    /// The URL generated from all the data set on this mock.
    private let generatedURL: URL

    /// The `URLRequest` to use if you did not set a specific URL.
    public let request: URLRequest

    /// If `true`, checking the URL will ignore the query and match only for the scheme, host and path.
    public let ignoreQuery: Bool

    /// The file extensions to match for.
    public let fileExtensions: [String]?

    /// The data which will be returned as the response based on the HTTP Method.
    private let data: [HTTPMethod: Data]

    /// Add a delay to a certain mock, which makes the response returned later.
    public var delay: DispatchTimeInterval?

    /// Allow response cache.
    public var cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed

    /// The callback which will be executed everytime this `Mock` was completed. Can be used within unit tests for validating that a request has been executed. The callback must be set before calling `register`.
    public var completion: (() -> Void)?

    /// The callback which will be executed everytime this `Mock` was started. Can be used within unit tests for validating that a request has been started. The callback must be set before calling `register`.
    @available(*, deprecated, message: "Use `onRequestHandler` instead.")
    public var onRequest: OnRequest? {
        set {
            onRequestHandler = OnRequestHandler(legacyCallback: newValue)
        }
        get {
            onRequestHandler?.legacyCallback
        }
    }

    /// The on request handler which will be executed everytime this `Mock` was started. Can be used within unit tests for validating that a request has been started. The handler must be set before calling `register`.
    public var onRequestHandler: OnRequestHandler?

    /// Optional response handler which could be used to dynamically generate the response
    public var responseHandler: ResponseHandler?

    /// Can only be set internally as it's used by the `expectationForRequestingMock(_:)` method.
    var onRequestExpectation: XCTestExpectation?

    /// Can only be set internally as it's used by the `expectationForCompletingMock(_:)` method.
    var onCompletedExpectation: XCTestExpectation?

    private init(url: URL? = nil, ignoreQuery: Bool = false, cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed, contentType: DataType? = nil, statusCode: Int, data: [HTTPMethod: Data], requestError: Error? = nil, additionalHeaders: [String: String] = [:], fileExtensions: [String]? = nil) {
        guard data.count > 0 else {
            preconditionFailure("At least one entry is required in the data dictionary")
        }
        
        self.urlToMock = url
        let generatedURL = URL(string: "https://mocked.wetransfer.com/\(contentType?.name ?? "no-content")/\(statusCode)/\(data.keys.first!.rawValue)")!
        self.generatedURL = generatedURL
        var request = URLRequest(url: url ?? generatedURL)
        request.httpMethod = data.keys.first!.rawValue
        self.request = request
        self.ignoreQuery = ignoreQuery
        self.requestError = requestError
        self.contentType = contentType
        self.statusCode = statusCode
        self.data = data
        self.cacheStoragePolicy = cacheStoragePolicy

        var headers = additionalHeaders
        if let contentType = contentType {
            headers["Content-Type"] = contentType.headerValue
        }
        self.headers = headers

        self.fileExtensions = fileExtensions?.map({ $0.replacingOccurrences(of: ".", with: "") })
    }

    /// Creates a `Mock` for the given data type. The mock will be automatically matched based on a URL created from the given parameters.
    ///
    /// - Parameters:
    ///   - dataType: The type of the data which designates the Content-Type header.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    @available(*, deprecated, renamed: "init(contentType:statusCode:data:additionalHeaders:)")
    public init(dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:]) {
        self.init(
            url: nil,
            contentType: dataType,
            statusCode: statusCode,
            data: data,
            additionalHeaders: additionalHeaders,
            fileExtensions: nil
        )
    }
    
    /// Creates a `Mock` for the given content type. The mock will be automatically matched based on a URL created from the given parameters.
    ///
    /// - Parameters:
    ///   - contentType: The type of the data which designates the Content-Type header. Defaults to `nil`, which means that no Content-Type header is added to the headers.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    public init(contentType: DataType?, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:]) {
        self.init(
            url: nil,
            contentType: contentType,
            statusCode: statusCode,
            data: data,
            additionalHeaders: additionalHeaders,
            fileExtensions: nil
        )
    }

    /// Creates a `Mock` for the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL to match for and to return the mocked data for.
    ///   - ignoreQuery: If `true`, checking the URL will ignore the query and match only for the scheme, host and path. Defaults to `false`.
    ///   - cacheStoragePolicy: The caching strategy. Defaults to `notAllowed`.
    ///   - dataType: The type of the data which designates the Content-Type header.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    ///   - requestError: If provided, the URLSession will report the passed error rather than returning data. Defaults to `nil`.
    @available(*, deprecated, renamed: "init(url:ignoreQuery:cacheStoragePolicy:contentType:statusCode:data:additionalHeaders:requestError:)")
    public init(url: URL, ignoreQuery: Bool = false, cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed, dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:], requestError: Error? = nil) {
        self.init(
            url: url,
            ignoreQuery: ignoreQuery,
            cacheStoragePolicy: cacheStoragePolicy,
            contentType: dataType,
            statusCode: statusCode,
            data: data,
            requestError: requestError,
            additionalHeaders: additionalHeaders,
            fileExtensions: nil
        )
    }
    
    /// Creates a `Mock` for the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL to match for and to return the mocked data for.
    ///   - ignoreQuery: If `true`, checking the URL will ignore the query and match only for the scheme, host and path. Defaults to `false`.
    ///   - cacheStoragePolicy: The caching strategy. Defaults to `notAllowed`.
    ///   - contentType: The type of the data which designates the Content-Type header. Defaults to `nil`, which means that no Content-Type header is added to the headers.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    ///   - requestError: If provided, the URLSession will report the passed error rather than returning data. Defaults to `nil`.
    public init(url: URL, ignoreQuery: Bool = false, cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed, contentType: DataType? = nil, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:], requestError: Error? = nil) {
        self.init(
            url: url,
            ignoreQuery: ignoreQuery,
            cacheStoragePolicy: cacheStoragePolicy,
            contentType: contentType,
            statusCode: statusCode,
            data: data,
            requestError: requestError,
            additionalHeaders: additionalHeaders,
            fileExtensions: nil
        )
    }
    
    /// Creates a `Mock` for the given file extensions. The mock will only be used for urls matching the extension.
    ///
    /// - Parameters:
    ///   - fileExtensions: The file extension to match for.
    ///   - dataType: The type of the data which designates the Content-Type header.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    @available(*, deprecated, renamed: "init(fileExtensions:contentType:statusCode:data:additionalHeaders:)")
    public init(fileExtensions: String..., dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:]) {
        self.init(
            url: nil,
            contentType: dataType,
            statusCode: statusCode,
            data: data,
            additionalHeaders: additionalHeaders,
            fileExtensions: fileExtensions
        )
    }
    
    /// Creates a `Mock` for the given file extensions. The mock will only be used for urls matching the extension.
    ///
    /// - Parameters:
    ///   - fileExtensions: The file extension to match for.
    ///   - contentType: The type of the data which designates the Content-Type header. Defaults to `nil`, which means that no Content-Type header is added to the headers.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    public init(fileExtensions: String..., contentType: DataType? = nil, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:]) {
        self.init(
            url: nil,
            contentType: contentType,
            statusCode: statusCode,
            data: data,
            additionalHeaders: additionalHeaders,
            fileExtensions: fileExtensions
        )
    }
    
    /// Creates a `Mock` for the given `URLRequest`.
    ///
    /// - Parameters:
    ///   - request: The URLRequest, from which the URL and request method is used to match for and to return the mocked data for.
    ///   - ignoreQuery: If `true`, checking the URL will ignore the query and match only for the scheme, host and path. Defaults to `false`.
    ///   - cacheStoragePolicy: The caching strategy. Defaults to `notAllowed`.
    ///   - contentType: The type of the data which designates the Content-Type header. Defaults to `nil`, which means that no Content-Type header is added to the headers.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response. Defaults to an empty `Data` instance.
    ///   - additionalHeaders: Additional headers to be added to the response.
    ///   - requestError: If provided, the URLSession will report the passed error rather than returning data. Defaults to `nil`.
    public init(request: URLRequest, ignoreQuery: Bool = false, cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed, contentType: DataType? = nil, statusCode: Int, data: Data = Data(), additionalHeaders: [String: String] = [:], requestError: Error? = nil) {
        guard let requestHTTPMethod = Mock.HTTPMethod(rawValue: request.httpMethod ?? "") else {
            preconditionFailure("Unexpected http method")
        }

        self.init(
            url: request.url,
            ignoreQuery: ignoreQuery,
            cacheStoragePolicy: cacheStoragePolicy,
            contentType: contentType,
            statusCode: statusCode,
            data: [requestHTTPMethod: data],
            requestError: requestError,
            additionalHeaders: additionalHeaders,
            fileExtensions: nil
        )
    }

    /// Creates a `Mock` for the given `URLRequest`.
    ///
    /// - Parameters:
    ///   - request: The URLRequest, from which the URL and request method is used to match for and to return the mocked data for.
    ///   - ignoreQuery: If `true`, checking the URL will ignore the query and match only for the scheme, host and path. Defaults to `false`.
    ///   - cacheStoragePolicy: The caching strategy. Defaults to `notAllowed`.
    ///   - responseHandler: The response handler to dynamicly generate the response for this Mock
    public init(request: URLRequest, ignoreQuery: Bool = false, cacheStoragePolicy: URLCache.StoragePolicy = .notAllowed, responseHandler: ResponseHandler) {
        guard let requestHTTPMethod = Mock.HTTPMethod(rawValue: request.httpMethod ?? "") else {
            preconditionFailure("Unexpected http method")
        }

        self.init(
            url: request.url,
            ignoreQuery: ignoreQuery,
            cacheStoragePolicy: cacheStoragePolicy,
            statusCode: 999, // unused, see responseHandler
            data: [requestHTTPMethod: "responseHandler should have been used instead of this".data(using: .utf8)!],
            fileExtensions: nil
        )

        self.responseHandler = responseHandler
    }

    /// Registers the mock with the shared `Mocker`.
    public func register() {
        Mocker.register(self)
    }

    /// Returns `Data` based on the HTTP Method of the passed request.
    ///
    /// - Parameter request: The request to match data for.
    /// - Returns: The `Data` which matches the request. Will be `nil` if no data is registered for the request `HTTPMethod`.
    func data(for request: URLRequest) -> Data? {
        guard let requestHTTPMethod = Mock.HTTPMethod(rawValue: request.httpMethod ?? "") else { return nil }
        return data[requestHTTPMethod]
    }

    /// Used to compare the Mock data with the given `URLRequest`.
    static func == (mock: Mock, request: URLRequest) -> Bool {
        guard let requestHTTPMethod = Mock.HTTPMethod(rawValue: request.httpMethod ?? "") else { return false }

        if let fileExtensions = mock.fileExtensions {
            // If the mock contains a file extension, this should always be used to match for.
            guard let pathExtension = request.url?.pathExtension else { return false }
            return fileExtensions.contains(pathExtension)
        }

        if mock.ignoreQuery {
            if mock.request.url!.baseString != request.url?.baseString {
                return false
            }
        } else if mock.request.url!.absoluteString != request.url?.absoluteString {
            return false
        }

        return mock.responseHandler != nil || mock.data.keys.contains(requestHTTPMethod)
    }

    public static func == (lhs: Mock, rhs: Mock) -> Bool {
        let lhsHTTPMethods: [String] = lhs.data.keys.compactMap { $0.rawValue }.sorted()
        let rhsHTTPMethods: [String] = rhs.data.keys.compactMap { $0.rawValue }.sorted()

        if let lhsFileExtensions = lhs.fileExtensions, let rhsFileExtensions = rhs.fileExtensions, (!lhsFileExtensions.isEmpty || !rhsFileExtensions.isEmpty) {
            /// The mocks are targeting file extensions specifically, check on those.
            return lhsFileExtensions == rhsFileExtensions && lhsHTTPMethods == rhsHTTPMethods
        }

        return lhs.request.url!.absoluteString == rhs.request.url!.absoluteString && lhsHTTPMethods == rhsHTTPMethods
    }
}
