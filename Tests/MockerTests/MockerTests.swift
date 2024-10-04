//
//  MockerTests.swift
//  MockerTests
//
//  Created by Antoine van der Lee on 11/08/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Mocker

final class MockerTests: XCTestCase {
    struct Framework {
        let name: String?
        let owner: String?

        init(jsonDictionary: [String: Any]) {
            name = jsonDictionary["name"] as? String
            owner = jsonDictionary["owner"] as? String
        }
    }

    override func setUp() {
        super.setUp()
        Mocker.mode = .optout
    }

    override func tearDown() {
        Mocker.removeAll()
        Mocker.mode = .optout
        super.tearDown()
    }

    /// It should returned the register mocked image data as response.
    func testImageURLDataRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://avatars3.githubusercontent.com/u/26250426?v=4&s=400")!

        let mockedData = MockedData.botAvatarImageFileUrl.data
        let mock = Mock(url: originalURL, contentType: .imagePNG, statusCode: 200, data: [
            .get: mockedData
        ])

        mock.register()
        URLSession.shared.dataTask(with: originalURL) { (data, _, error) in
            XCTAssertNil(error)
            XCTAssertEqual(data, mockedData, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should returned the register mocked image data as response for register file types.
    func testImageExtensionDataRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")

        let mockedData = MockedData.botAvatarImageFileUrl.data
        Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 200, data: [
            .get: mockedData
        ]).register()

        URLSession.shared.dataTask(with: originalURL!) { (data, _, error) in
            XCTAssertNil(error)
            XCTAssertEqual(data, mockedData, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should ignore file extension mocks if a specific URL is mocked.
    func testSpecificURLOverGenericMocks() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")!

        Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 400, data: [
            .get: Data()
        ]).register()

        let mockedData = MockedData.botAvatarImageFileUrl.data
        Mock(url: originalURL, ignoreQuery: true, contentType: .imagePNG, statusCode: 200, data: [
            .get: mockedData
        ]).register()

        URLSession.shared.dataTask(with: originalURL) { (data, _, error) in
            XCTAssertNil(error)
            XCTAssertEqual(data, mockedData, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should correctly ignore queries if set.
    func testIgnoreQueryMocking() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png?width=200&height=200")!

        let mockedData = MockedData.botAvatarImageFileUrl.data
        Mock(url: originalURL, ignoreQuery: true, contentType: .imagePNG, statusCode: 200, data: [
            .get: mockedData
        ]).register()

        /// Make it different compared to the mocked URL.
        let customURL = URL(string: originalURL.absoluteString + "&" + UUID().uuidString)!

        URLSession.shared.dataTask(with: customURL) { (data, _, error) in
            XCTAssertNil(error)
            XCTAssertEqual(data, mockedData, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should return the mocked JSON.
    func testJSONRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/example.json")!

        Mock(url: originalURL, contentType: .json, statusCode: 200, data: [
            .get: MockedData.exampleJSON.data
        ]).register()

        URLSession.shared.dataTask(with: originalURL) { (data, _, _) in

            guard let data = data else {
                XCTFail("Data is nil")
                return
            }

            guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                XCTFail("Wrong data response \(String(describing: data))")
                expectation.fulfill()
                return
            }

            let framework = Framework(jsonDictionary: jsonDictionary)
            XCTAssertEqual(framework.name, "Mocker")
            XCTAssertEqual(framework.owner, "WeTransfer")

            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// No Content-Type should be included in the headers
    func testNoContentType() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/api/foobar")!
        var request = URLRequest(url: originalURL)
        request.httpMethod = "PUT"

        Mock(request: request, statusCode: 202).register()

        URLSession.shared.dataTask(with: request) { (data, response, _) in
            guard let response = response as? HTTPURLResponse else {
                XCTFail("Unexpected response")
                return
            }
            
            // data is only nil if there is an error
            XCTAssertEqual(data, Data())
            XCTAssertNil(response.allHeaderFields["Content-Type"])

            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should return the additional headers.
    func testAdditionalHeaders() {
        let expectation = self.expectation(description: "Data request should succeed")
        let headers = ["Testkey": "testvalue"]
        let mock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()], additionalHeaders: headers)
        mock.register()

        URLSession.shared.dataTask(with: mock.request) { (_, response, error) in
            XCTAssertNil(error)
            XCTAssertEqual(((response as? HTTPURLResponse)?.allHeaderFields["Testkey"] as? String), "testvalue", "Additional headers should be added.")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should override existing mocks.
    func testMockOverriding() {
        let expectation = self.expectation(description: "Data request should succeed")
        let mock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()], additionalHeaders: ["testkey": "testvalue"])
        mock.register()

        let newMock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()], additionalHeaders: ["Newkey": "newvalue"])
        newMock.register()

        URLSession.shared.dataTask(with: mock.request) { (_, response, error) in
            XCTAssertNil(error)
            XCTAssertEqual(((response as? HTTPURLResponse)?.allHeaderFields["Newkey"] as? String), "newvalue", "Additional headers should be added.")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should work with a custom URLSession.
    func testCustomURLSession() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")

        let mockedData = MockedData.botAvatarImageFileUrl.data
        Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 200, data: [
            .get: mockedData
        ]).register()

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        urlSession.dataTask(with: originalURL!) { (data, _, error) in
            XCTAssertNil(error)
            XCTAssertEqual(data, mockedData, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should be possible to test cancellation of requests with a delayed mock.
    func testDelayedMockCancelation() {
        let expectation = self.expectation(description: "Data request should be cancelled")
        var mock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()])
        mock.delay = DispatchTimeInterval.seconds(5)
        mock.register()

        let task = URLSession.shared.dataTask(with: mock.request) { (_, _, error) in
            XCTAssertEqual(error?._code, NSURLErrorCancelled)
            expectation.fulfill()
        }

        task.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            task.cancel()
        })
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should correctly handle redirect responses.
    func testRedirectResponse() throws {
        #if os(Linux)
        throw XCTSkip("The URLSession swift-corelibs-foundation implementation doesn't currently handle redirects directly")
        #endif
        let expectation = self.expectation(description: "Data request should be cancelled")
        let urlWhichRedirects: URL = URL(string: "https://we.tl/redirect")!
        Mock(url: urlWhichRedirects, contentType: .html, statusCode: 200, data: [.get: MockedData.redirectGET.data]).register()
        Mock(url: URL(string: "https://wetransfer.com/redirect")!, contentType: .json, statusCode: 200, data: [.get: MockedData.exampleJSON.data]).register()

        URLSession.shared.dataTask(with: urlWhichRedirects) { (data, _, _) in

            guard let data = data else {
                XCTFail("Data is nil")
                return
            }

            guard let jsonDictionary = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                XCTFail("Wrong data response \(String(describing: data))")
                expectation.fulfill()
                return
            }

            let framework = Framework(jsonDictionary: jsonDictionary)
            XCTAssertEqual(framework.name, "Mocker")
            XCTAssertEqual(framework.owner, "WeTransfer")

            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should be possible to ignore URLs and not let them be handled.
    func testIgnoreURLs() {

        let ignoredURL = URL(string: "www.wetransfer.com")!

        XCTAssertTrue(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)))
        Mocker.ignore(ignoredURL)
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)))
    }

    /// It should be possible to ignore URLs and not let them be handled.
    func testIgnoreURLsIgnoreQueries() {

        let ignoredURL = URL(string: "https://www.wetransfer.com/sample-image.png")!
        let ignoredURLQueries = URL(string: "https://www.wetransfer.com/sample-image.png?width=200&height=200")!

        XCTAssertTrue(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURLQueries)))
        Mocker.ignore(ignoredURL, matchType: .ignoreQuery)
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURLQueries)))
    }

    /// It should be possible to ignore URL prefixes and not let them be handled.
    func testIgnoreURLsIgnorePrefixes() {

        let ignoredURL = URL(string: "https://www.wetransfer.com/private")!
        let ignoredURLSubPath = URL(string: "https://www.wetransfer.com/private/sample-image.png")!

        XCTAssertTrue(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURLSubPath)))
        Mocker.ignore(ignoredURL, matchType: .prefix)
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURLSubPath)))
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)))
    }

    /// It should be possible to compose a url relative to a base and still have it match the full url
    func testComposedURLMatch() {
        let composedURL = URL(fileURLWithPath: "resource", relativeTo: URL(string: "https://host.com/api/"))
        let simpleURL = URL(string: "https://host.com/api/resource")
        let mock = Mock(url: composedURL, contentType: .json, statusCode: 200, data: [.get: MockedData.exampleJSON.data])
        let urlRequest = URLRequest(url: simpleURL!)
        XCTAssertEqual(composedURL.absoluteString, simpleURL?.absoluteString)
        XCTAssert(mock == urlRequest)
    }

    /// It should call the onRequest and completion callbacks when a `Mock` is used and completed in the right order.
    func testMockCallbacks() {
        let onRequestExpectation = expectation(description: "Data request should start")
        let completionExpectation = expectation(description: "Data request should succeed")
        var mock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()])
        mock.onRequest = { _, _ in
            onRequestExpectation.fulfill()
        }
        mock.completion = {
            completionExpectation.fulfill()
        }
        mock.register()

        URLSession.shared.dataTask(with: mock.request).resume()

        wait(for: [onRequestExpectation, completionExpectation], timeout: 2.0, enforceOrder: true)
    }

    /// It should report post body arguments if they exist.
    func testOnRequestLegacyPostBodyParameters() throws {
        let onRequestExpectation = expectation(description: "Data request should start")

        let expectedParameters = ["test": "value"]
        let requestURL = URL(string: "https://www.fakeurl.com")!
        var request = URLRequest(url: requestURL)
        request.httpMethod = Mock.HTTPMethod.post.rawValue
        request.httpBody = try JSONSerialization.data(withJSONObject: expectedParameters, options: .prettyPrinted)

        var mock = Mock(url: requestURL, contentType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequest = { request, postBodyArguments in
            XCTAssertEqual(request.url, requestURL)
            XCTAssertEqual(expectedParameters, postBodyArguments as? [String: String])
            onRequestExpectation.fulfill()
        }
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    func testOnRequestDecodablePostBodyParameters() throws {
        struct RequestParameters: Codable, Equatable {
            let name: String
        }

        let onRequestExpectation = expectation(description: "Data request should start")

        let expectedParameters = RequestParameters(name: UUID().uuidString)
        let requestURL = URL(string: "https://www.fakeurl.com")!
        var request = URLRequest(url: requestURL)
        request.httpMethod = Mock.HTTPMethod.post.rawValue
        request.httpBody = try JSONEncoder().encode(expectedParameters)

        var mock = Mock(url: request.url!, contentType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequestHandler = .init(httpBodyType: RequestParameters.self, callback: { request, postBodyDecodable in
            XCTAssertEqual(request.url, requestURL)
            XCTAssertEqual(expectedParameters, postBodyDecodable)
            onRequestExpectation.fulfill()
        })
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    func testOnRequestDecodablePostBodyParametersWithCustomJSONDecoder() throws {
        struct RequestParameters: Codable, Equatable {
            let name: String
        }

        let onRequestExpectation = expectation(description: "Data request should start")

        let expectedParameters = RequestParameters(name: UUID().uuidString)
        let requestURL = URL(string: "https://www.fakeurl.com")!
        var request = URLRequest(url: requestURL)
        request.httpMethod = Mock.HTTPMethod.post.rawValue
        request.httpBody = try JSONEncoder().encode(expectedParameters)

        var mock = Mock(url: request.url!, contentType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequestHandler = .init(httpBodyType: RequestParameters.self, jsonDecoder: JSONDecoder(), callback: { request, postBodyDecodable in
            XCTAssertEqual(request.url, requestURL)
            XCTAssertEqual(expectedParameters, postBodyDecodable)
            onRequestExpectation.fulfill()
        })
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    func testOnRequestJSONDictionaryPostBodyParameters() throws {
        let onRequestExpectation = expectation(description: "Data request should start")

        let expectedParameters = ["test": "value"]
        let requestURL = URL(string: "https://www.fakeurl.com")!
        var request = URLRequest(url: requestURL)
        request.httpMethod = Mock.HTTPMethod.post.rawValue
        request.httpBody = try JSONSerialization.data(withJSONObject: expectedParameters, options: .prettyPrinted)

        var mock = Mock(url: request.url!, contentType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequestHandler = .init(jsonDictionaryCallback: { request, postBodyArguments in
            XCTAssertEqual(request.url, requestURL)
            XCTAssertEqual(expectedParameters, postBodyArguments as? [String: String])
            onRequestExpectation.fulfill()
        })
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    func testOnRequestCallbackWithoutRequestAndParameters() throws {
        let onRequestExpectation = expectation(description: "Data request should start")

        var request = URLRequest(url: URL(string: "https://www.fakeurl.com")!)
        request.httpMethod = Mock.HTTPMethod.post.rawValue

        var mock = Mock(url: request.url!, contentType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequestHandler = .init(callback: {
            onRequestExpectation.fulfill()
        })
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    /// It should report post body arguments with top level collection type if they exist.
    func testOnRequestPostBodyParametersWithTopLevelCollectionType() throws {
        let onRequestExpectation = expectation(description: "Data request should start")

        let expectedParameters = [["test": "value"], ["test": "value"]]
        let requestURL = URL(string: "https://www.fakeurl.com")!
        var request = URLRequest(url: requestURL)
        request.httpMethod = Mock.HTTPMethod.post.rawValue
        request.httpBody = try JSONSerialization.data(withJSONObject: expectedParameters, options: .prettyPrinted)

        var mock = Mock(url: request.url!, contentType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequestHandler = OnRequestHandler(jsonArrayCallback: { request, postBodyArguments in
            XCTAssertEqual(request.url, requestURL)
            XCTAssertEqual(expectedParameters, postBodyArguments as? [[String: String]])
            onRequestExpectation.fulfill()
        })
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    func testResponseHandler() {
        let requestExpectation = self.expectation(description: "Data request should succeed")
        let responseHandlerExpectation = self.expectation(description: "Data request should start")
        let originalURL = URL(string: "https://avatars3.githubusercontent.com/u/26250426?v=4&s=400")!
        var request = URLRequest(url: originalURL)

        let mockedData = MockedData.botAvatarImageFileUrl.data
        let mock = Mock(request: request, responseHandler: ResponseHandler(callback: {
            responseHandlerExpectation.fulfill()
            return (
                HTTPURLResponse(
                    url: originalURL,
                    statusCode: 200,
                    httpVersion: Mocker.httpVersion.rawValue,
                    headerFields: nil
                )!,
                mockedData
            )
        }))
        mock.register()

        mock.register()
        URLSession.shared.dataTask(with: originalURL) { (data, _, error) in
            XCTAssertNil(error)
            XCTAssertEqual(data, mockedData, "Image should be returned mocked")
            requestExpectation.fulfill()
        }.resume()


        wait(for: [responseHandlerExpectation, requestExpectation], enforceOrder: true)
    }

    /// It should call the mock after a delay.
    func testDelayedMock() {
        let nonDelayExpectation = expectation(description: "Data request should succeed")
        let delayedExpectation = expectation(description: "Data request should succeed")
        var delayedMock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()])
        delayedMock.delay = DispatchTimeInterval.seconds(1)
        delayedMock.completion = {
            delayedExpectation.fulfill()
        }
        delayedMock.register()
        var nonDelayMock = Mock(contentType: .json, statusCode: 200, data: [.post: Data()])
        nonDelayMock.completion = {
            nonDelayExpectation.fulfill()
        }
        nonDelayMock.register()

        XCTAssertNotEqual(delayedMock.request.url, nonDelayMock.request.url)

        URLSession.shared.dataTask(with: delayedMock.request).resume()
        URLSession.shared.dataTask(with: nonDelayMock.request).resume()

        wait(for: [nonDelayExpectation, delayedExpectation], timeout: 2.0, enforceOrder: true)
    }

    /// It should remove all registered mocks correctly.
    func testRemoveAll() {
        let mock = Mock(contentType: .json, statusCode: 200, data: [.get: Data()])
        mock.register()
        Mocker.removeAll()
        XCTAssertTrue(Mocker.shared.mocks.isEmpty)
    }

    /// It should correctly add two mocks for the same URL if the HTTP method is different.
    func testDifferentHTTPMethodSameURL() {
        let url = URL(string: "https://www.fakeurl.com/\(UUID().uuidString)")!
        Mock(url: url, contentType: .json, statusCode: 200, data: [.get: Data()]).register()
        Mock(url: url, contentType: .json, statusCode: 200, data: [.put: Data()]).register()
        var request = URLRequest(url: url)
        request.httpMethod = Mock.HTTPMethod.get.rawValue
        XCTAssertNotNil(Mocker.mock(for: request))
        request.httpMethod = Mock.HTTPMethod.put.rawValue
        XCTAssertNotNil(Mocker.mock(for: request))
    }

    /// It should call the on request expectation.
    func testOnRequestExpectation() {
        let url = URL(string: "https://www.fakeurl.com")!

        var mock = Mock(url: url, contentType: .json, statusCode: 200, data: [.get: Data()])
        let expectation = expectationForRequestingMock(&mock)
        mock.register()

        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()

        wait(for: [expectation], timeout: 2.0)
    }

    /// It should call the on completion expectation.
    func testOnCompletionExpectation() {
        let url = URL(string: "https://www.fakeurl.com")!

        var mock = Mock(url: url, contentType: .json, statusCode: 200, data: [.get: Data()])
        let expectation = expectationForCompletingMock(&mock)
        mock.register()

        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()

        wait(for: [expectation], timeout: 2.0)
    }

    /// it should return the error we requested from the mock when we pass in an Error.
    func testMockReturningError() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/example.json")!

        enum TestExampleError: Error, LocalizedError {
            case example

            var errorDescription: String { "example" }
        }

        Mock(url: originalURL, contentType: .json, statusCode: 500, data: [.get: Data()], requestError: TestExampleError.example).register()

        URLSession.shared.dataTask(with: originalURL) { (data, urlresponse, error) in

            XCTAssertNil(data)
            XCTAssertNil(urlresponse)
            XCTAssertNotNil(error)
            if let error = error {
                #if os(Linux)
                XCTAssertEqual(error as? TestExampleError, .example)
                #else
                // there's not a particularly elegant way to verify an instance
                // of an error, but this is a convenient workaround for testing
                // purposes
                XCTAssertTrue(String(describing: error).contains("TestExampleError"))
                #endif
            }

            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should cache response
    func testMockCachePolicy() throws {
        #if os(Linux)
        throw XCTSkip("URLSessionTask in swift-corelibs-foundation doesn't cache response for custom protocols")
        #endif
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/example.json")!

        Mock(url: originalURL, cacheStoragePolicy: .allowed,
             contentType: .json, statusCode: 200,
             data: [.get: MockedData.exampleJSON.data],
             additionalHeaders: ["Cache-Control": "public, max-age=31557600, immutable"]
        ).register()

        let configuration = URLSessionConfiguration.default
        #if !os(Linux)
        configuration.urlCache = URLCache()
        #endif
        configuration.protocolClasses = [MockingURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)

        urlSession.dataTask(with: originalURL) { (_, _, error) in
            XCTAssertNil(error)

            let cachedResponse = configuration.urlCache?.cachedResponse(for: URLRequest(url: originalURL))
            XCTAssertNotNil(cachedResponse)
            XCTAssertEqual(cachedResponse!.data, MockedData.exampleJSON.data)

            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should process unknown URL
    func testMockerOptoutMode() {
        Mocker.mode = .optout

        let mockedURL = URL(string: "www.google.com")!
        let ignoredURL = URL(string: "www.wetransfer.com")!
        let unknownURL = URL(string: "www.netflix.com")!

        // Mocking
        Mock(url: mockedURL, contentType: .json, statusCode: 200, data: [.get: Data()])
            .register()

        // Ignoring
        Mocker.ignore(ignoredURL)

        // Checking mocked URL are processed by Mocker
        XCTAssertTrue(MockingURLProtocol.canInit(with: URLRequest(url: mockedURL)))
        // Checking ignored URL are not processed by Mocker
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)))

        // Checking unknown URL are processed by Mocker (.optout mode)
        XCTAssertTrue(MockingURLProtocol.canInit(with: URLRequest(url: unknownURL)))
    }

    /// It should not process unknown URL
    func testMockerOptinMode() {
        Mocker.mode = .optin

        let mockedURL = URL(string: "www.google.com")!
        let ignoredURL = URL(string: "www.wetransfer.com")!
        let unknownURL = URL(string: "www.netflix.com")!

        // Mocking
        Mock(url: mockedURL, contentType: .json, statusCode: 200, data: [.get: Data()])
            .register()

        // Ignoring
        Mocker.ignore(ignoredURL)

        // Checking mocked URL are processed by Mocker
        XCTAssertTrue(MockingURLProtocol.canInit(with: URLRequest(url: mockedURL)))
        // Checking ignored URL are not processed by Mocker
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)))

        // Checking unknown URL are not processed by Mocker (.optin mode)
        XCTAssertFalse(MockingURLProtocol.canInit(with: URLRequest(url: unknownURL)))
    }

    /// Default mode should be .optout
    func testDefaultMode() {
        /// Checking default mode
        XCTAssertEqual(.optout, Mocker.mode)
    }
}
