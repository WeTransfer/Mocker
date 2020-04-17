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

/// A Mock which can be used for mocking data requests with the `Mocker` by calling `Mocker.register(...)`.
public struct Mock: Equatable {

    /// HTTP method definitions.
    ///
    /// See https://tools.ietf.org/html/rfc7231#section-4.3
    public enum HTTPMethod: String {
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
    
    /// The types of content of a request. Will be used as Content-Type header inside a `Mock`.
    public enum DataType: String {
        case json
        case html
        case imagePNG
        case pdf
        case mp4
        case zip
        
        var headerValue: String {
            switch self {
            case .json:
                return "application/json; charset=utf-8"
            case .html:
                return "text/html; charset=utf-8"
            case .imagePNG:
                return "image/png"
            case .pdf:
                return "application/pdf"
            case .mp4:
                return "video/mp4"
            case .zip:
                return "application/zip"
            }
        }
    }

    public typealias OnRequest = (_ request: URLRequest, _ httpBodyArguments: [String: Any]?) -> Void
    
    /// The type of the data which is returned.
    public let dataType: DataType
    
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

    /// The callback which will be executed everytime this `Mock` was completed. Can be used within unit tests for validating that a request has been executed. The callback must be set before calling `register`.
    public var completion: (() -> Void)?

    /// The callback which will be executed everytime this `Mock` was started. Can be used within unit tests for validating that a request has been started. The callback must be set before calling `register`.
    public var onRequest: OnRequest?
    
    private init(url: URL? = nil, ignoreQuery: Bool = false, dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], requestError: Error? = nil, additionalHeaders: [String: String] = [:], fileExtensions: [String]? = nil) {
        self.urlToMock = url
        let generatedURL = URL(string: "https://mocked.wetransfer.com/\(dataType.rawValue)/\(statusCode)/\(data.keys.first!.rawValue)")!
        self.generatedURL = generatedURL
        var request = URLRequest(url: url ?? generatedURL)
        request.httpMethod = data.keys.first!.rawValue
        self.request = request
        self.ignoreQuery = ignoreQuery
        self.requestError = requestError
        self.dataType = dataType
        self.statusCode = statusCode
        self.data = data

        var headers = additionalHeaders
        headers["Content-Type"] = dataType.headerValue
        self.headers = headers

        self.fileExtensions = fileExtensions?.map({ $0.replacingOccurrences(of: ".", with: "") })
    }
    
    /// Creates a `Mock` for the given data type. The mock will be automatically matched based on a URL created from the given parameters.
    ///
    /// - Parameters:
    ///   - dataType: The type of the data which is returned.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    public init(dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:]) {
        self.init(url: nil, dataType: dataType, statusCode: statusCode, data: data, additionalHeaders: additionalHeaders, fileExtensions: nil)
    }
    
    /// Creates a `Mock` for the given URL.
    ///
    /// - Parameters:
    ///   - url: The URL to match for and to return the mocked data for.
    ///   - ignoreQuery: If `true`, checking the URL will ignore the query and match only for the scheme, host and path. Defaults to `false`.
    ///   - reportFailure: if `true`, the URLsession will report an error loading the URL rather than returning data. Defaults to `false`.
    ///   - dataType: The type of the data which is returned.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    public init(url: URL, ignoreQuery: Bool = false, dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:], requestError: Error? = nil) {
        self.init(url: url, ignoreQuery: ignoreQuery, dataType: dataType, statusCode: statusCode, data: data, requestError: requestError, additionalHeaders: additionalHeaders, fileExtensions: nil)
    }
    
    /// Creates a `Mock` for the given file extensions. The mock will only be used for urls matching the extension.
    ///
    /// - Parameters:
    ///   - fileExtensions: The file extension to match for.
    ///   - dataType: The type of the data which is returned.
    ///   - statusCode: The HTTP status code to return with the response.
    ///   - data: The data which will be returned as the response based on the HTTP Method.
    ///   - additionalHeaders: Additional headers to be added to the response.
    public init(fileExtensions: String..., dataType: DataType, statusCode: Int, data: [HTTPMethod: Data], additionalHeaders: [String: String] = [:]) {
        self.init(url: nil, dataType: dataType, statusCode: statusCode, data: data, additionalHeaders: additionalHeaders, fileExtensions: fileExtensions)
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
        } else if mock.ignoreQuery {
            return mock.request.url!.baseString == request.url?.baseString && mock.data.keys.contains(requestHTTPMethod)
        }

        return mock.request.url!.absoluteString == request.url?.absoluteString && mock.data.keys.contains(requestHTTPMethod)
    }
    
    public static func == (lhs: Mock, rhs: Mock) -> Bool {
        let lhsHTTPMethods: [String] = lhs.data.keys.compactMap { $0.rawValue }
        let rhsHTTPMethods: [String] = rhs.data.keys.compactMap { $0.rawValue }
        return lhs.request.url!.absoluteString == rhs.request.url!.absoluteString && lhsHTTPMethods == rhsHTTPMethods
    }
}

private extension URL {
    /// Returns the base URL string build with the scheme, host and path. "https://www.wetransfer.com/v1/test?param=test" would be "https://www.wetransfer.com/v1/test".
    var baseString: String? {
        guard let scheme = scheme, let host = host else { return nil }
        return scheme + "://" + host + path
    }
}
