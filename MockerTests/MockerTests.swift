//
//  MockerTests.swift
//  MockerTests
//
//  Created by Antoine van der Lee on 11/08/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import XCTest
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
        
        // make sure this is cleared before each test to avoid bleed-over between tests.
        Mocker.onMockFor = nil
    }
    
    /// It should returned the register mocked image data as response.
    func testImageURLDataRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://avatars3.githubusercontent.com/u/26250426?v=4&s=400")!
        
        let mock = Mock(url: originalURL, dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.botAvatarImageFileUrl.data
        ])
        
        mock.register()
        URLSession.shared.dataTask(with: originalURL) { (data, _, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: MockedData.botAvatarImageFileUrl.path)!
            
            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should returned the register mocked image data as response for register file types.
    func testImageExtensionDataRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")
        
        Mock(fileExtensions: "png", dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.botAvatarImageFileUrl.data
        ]).register()
        
        URLSession.shared.dataTask(with: originalURL!) { (data, _, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: MockedData.botAvatarImageFileUrl.path)!
            
            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should ignore file extension mocks if a specific URL is mocked.
    func testSpecificURLOverGenericMocks() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")!

        Mock(fileExtensions: "png", dataType: .imagePNG, statusCode: 400, data: [
            .get: Data()
        ]).register()
        Mock(url: originalURL, ignoreQuery: true, dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.botAvatarImageFileUrl.data
        ]).register()

        URLSession.shared.dataTask(with: originalURL) { (data, _, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: MockedData.botAvatarImageFileUrl.path)!

            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should correctly ignore queries if set.
    func testIgnoreQueryMocking() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png?width=200&height=200")!

        Mock(url: originalURL, ignoreQuery: true, dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.botAvatarImageFileUrl.data
        ]).register()

        /// Make it different compared to the mocked URL.
        let customURL = URL(string: originalURL.absoluteString + "&" + UUID().uuidString)!

        URLSession.shared.dataTask(with: customURL) { (data, _, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: MockedData.botAvatarImageFileUrl.path)!

            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()

        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should return the mocked JSON.
    func testJSONRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/example.json")!
        
        Mock(url: originalURL, dataType: .json, statusCode: 200, data: [
            .get: MockedData.exampleJSON.data
            ]
        ).register()
        
        URLSession.shared.dataTask(with: originalURL) { (data, _, _) in

            guard let data = data, let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                XCTFail("Wrong data response")
                expectation.fulfill()
                return
            }
            
            let framework = Framework(jsonDictionary: jsonDictionary)
            XCTAssert(framework.name == "Mocker")
            XCTAssert(framework.owner == "WeTransfer")
            
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should return the additional headers.
    func testAdditionalHeaders() {
        let expectation = self.expectation(description: "Data request should succeed")
        let headers = ["testkey": "testvalue"]
        let mock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()], additionalHeaders: headers)
        mock.register()
        
        URLSession.shared.dataTask(with: mock.request) { (_, response, error) in
            XCTAssert(error == nil)
            XCTAssert(((response as! HTTPURLResponse).allHeaderFields["testkey"] as! String) == "testvalue", "Additional headers should be added.")
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should override existing mocks.
    func testMockOverriding() {
        let expectation = self.expectation(description: "Data request should succeed")
        let mock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()], additionalHeaders: ["testkey": "testvalue"])
        mock.register()
        
        let newMock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()], additionalHeaders: ["newkey": "newvalue"])
        newMock.register()
        
        URLSession.shared.dataTask(with: mock.request) { (_, response, error) in
            XCTAssert(error == nil)
            XCTAssert(((response as! HTTPURLResponse).allHeaderFields["newkey"] as! String) == "newvalue", "Additional headers should be added.")
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should work with a custom URLSession.
    func testCustomURLSession() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")
        
        Mock(fileExtensions: "png", dataType: .imagePNG, statusCode: 200, data: [
            .get: MockedData.botAvatarImageFileUrl.data
        ]).register()
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        urlSession.dataTask(with: originalURL!) { (data, _, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: MockedData.botAvatarImageFileUrl.path)!
            
            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
            }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should be possible to test cancellation of requests with a delayed mock.
    func testDelayedMockCancelation() {
        let expectation = self.expectation(description: "Data request should be cancelled")
        var mock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()])
        mock.delay = DispatchTimeInterval.seconds(5)
        mock.register()
        
        let task = URLSession.shared.dataTask(with: mock.request) { (_, _, error) in
            XCTAssert(error?._code == NSURLErrorCancelled)
            expectation.fulfill()
        }
        
        task.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            task.cancel()
        })
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should correctly handle redirect responses.
    func testRedirectResponse() {
        let expectation = self.expectation(description: "Data request should be cancelled")
        let urlWhichRedirects: URL = URL(string: "https://we.tl/redirect")!
        Mock(url: urlWhichRedirects, dataType: .html, statusCode: 200, data: [.get: MockedData.redirectGET.data]).register()
        Mock(url: URL(string: "https://wetransfer.com/redirect")!, dataType: .json, statusCode: 200, data: [.get: MockedData.exampleJSON.data]).register()
        
        URLSession.shared.dataTask(with: urlWhichRedirects) { (data, _, _) in
            
            guard let data = data, let jsonDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                XCTFail("Wrong data response")
                expectation.fulfill()
                return
            }
            
            let framework = Framework(jsonDictionary: jsonDictionary)
            XCTAssert(framework.name == "Mocker")
            XCTAssert(framework.owner == "WeTransfer")
            
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should be possible to ignore URLs and not let them be handled.
    func testIgnoreURLs() {
        
        let ignoredURL = URL(string: "www.wetransfer.com")!
        
        XCTAssert(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)) == true)
        Mocker.ignore(ignoredURL)
        XCTAssert(MockingURLProtocol.canInit(with: URLRequest(url: ignoredURL)) == false)
    }
    
    /// It should be possible to compose a url relative to a base and still have it match the full url
    func testComposedURLMatch() {
        let composedURL = URL(fileURLWithPath: "resource", relativeTo: URL(string: "https://host.com/api/"))
        let simpleURL = URL(string: "https://host.com/api/resource")
        let mock = Mock(url: composedURL, dataType: .json, statusCode: 200, data: [.get: MockedData.exampleJSON.data])
        let urlRequest = URLRequest(url: simpleURL!)
        XCTAssertEqual(composedURL.absoluteString, simpleURL!.absoluteString)
        XCTAssert(mock == urlRequest)
    }

    /// It should call the onRequest and completion callbacks when a `Mock` is used and completed in the right order.
    func testMockCallbacks() {
        let onRequestExpectation = expectation(description: "Data request should start")
        let completionExpectation = expectation(description: "Data request should succeed")
        var mock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()])
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
    func testOnRequestPostBodyParameters() throws {
        let onRequestExpectation = expectation(description: "Data request should start")

        let expectedParameters = ["test": "value"]
        var request = URLRequest(url: URL(string: "https://www.fakeurl.com")!)
        request.httpMethod = Mock.HTTPMethod.post.rawValue
        request.httpBody = try JSONSerialization.data(withJSONObject: expectedParameters, options: .prettyPrinted)

        var mock = Mock(url: request.url!, dataType: .json, statusCode: 200, data: [.post: Data()])
        mock.onRequest = { request, postBodyArguments in
            XCTAssertEqual(request.url, mock.request.url)
            XCTAssertEqual(expectedParameters, postBodyArguments as? [String: String])
            onRequestExpectation.fulfill()
        }
        mock.register()

        URLSession.shared.dataTask(with: request).resume()

        wait(for: [onRequestExpectation], timeout: 2.0)
    }

    /// It should call the mock after a delay.
    func testDelayedMock() {
        let nonDelayExpectation = expectation(description: "Data request should succeed")
        let delayedExpectation = expectation(description: "Data request should succeed")
        var delayedMock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()])
        delayedMock.delay = DispatchTimeInterval.seconds(1)
        delayedMock.completion = {
            delayedExpectation.fulfill()
        }
        delayedMock.register()
        var nonDelayMock = Mock(dataType: .json, statusCode: 200, data: [.post: Data()])
        nonDelayMock.completion = {
            nonDelayExpectation.fulfill()
        }
        nonDelayMock.register()

        XCTAssertNotEqual(delayedMock.request.url!, nonDelayMock.request.url!)

        URLSession.shared.dataTask(with: delayedMock.request).resume()
        URLSession.shared.dataTask(with: nonDelayMock.request).resume()

        wait(for: [nonDelayExpectation, delayedExpectation], timeout: 2.0, enforceOrder: true)
    }

    /// It should remove all registered mocks correctly.
    func testRemoveAll() {
        let mock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()])
        mock.register()
        Mocker.removeAll()
        XCTAssertTrue(Mocker.shared.mocks.isEmpty)
    }

    /// It should correctly add two mocks for the same URL if the HTTP method is different.
    func testDifferentHTTPMethodSameURL() {
        let url = URL(string: "https://www.fakeurl.com/\(UUID().uuidString)")!
        Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()]).register()
        Mock(url: url, dataType: .json, statusCode: 200, data: [.put: Data()]).register()
        var request = URLRequest(url: url)
        request.httpMethod = Mock.HTTPMethod.get.rawValue
        XCTAssertNotNil(Mocker.mock(for: request))
        request.httpMethod = Mock.HTTPMethod.put.rawValue
        XCTAssertNotNil(Mocker.mock(for: request))
    }

    /// It should call the on request expectation.
    func testOnRequestExpectation() {
        let url = URL(string: "https://www.fakeurl.com")!

        var mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()])
        let expectation = expectationForRequestingMock(&mock)
        mock.register()

        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()

        wait(for: [expectation], timeout: 2.0)
    }

    /// It should call the on completion expectation.
    func testOnCompletionExpectation() {
        let url = URL(string: "https://www.fakeurl.com")!

        var mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()])
        let expectation = expectationForCompletingMock(&mock)
        mock.register()

        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()

        wait(for: [expectation], timeout: 2.0)
    }
    
    /// it should return the error we requested from the mock when we pass in an Error.
    func testMockReturningError() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/example.json")!

        enum TestExampleError: Error {
            case example
        }
        
        Mock(url: originalURL, dataType: .json, statusCode: 500, data: [.get: Data()], requestError: TestExampleError.example).register()
        
        URLSession.shared.dataTask(with: originalURL) { (data, urlresponse, err) in

            XCTAssertNil(data)
            XCTAssertNil(urlresponse)
            XCTAssertNotNil(err)
            if let err = err {
                // there's not a particularly elegant way to verify an instance
                // of an error, but this is a convenient workaround for testing
                // purposes
                XCTAssertEqual("example", String(describing: err))
            }
            
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    /// It should call the `onMockFor` filter closure if set.
    func testOnMockForFilterCalled() {
        let url = URL(string: "https://www.fakeurl.com/DynamicTests")!
        var onMockForCalled = false
        
        Mocker.onMockFor = { (request: URLRequest) -> Mock? in
            onMockForCalled = true
            return nil
        }
        
        var mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()])
        let expectation = expectationForCompletingMock(&mock)
        mock.register()
        
        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssert(onMockForCalled, "our onMockFor handler was not called!")
    }
    
    /// It should use the replacement mock set in the `onMockFor` filter closure
    func testOnMockForReplacementMockUsed() {
        let url = URL(string: "https://www.fakeurl.com")!
        let injectedMockData = "{\"key\":\"value\"}".data(using: .utf8)!
        
        Mocker.onMockFor = { (request: URLRequest) -> Mock? in
            return Mock(dataType: .json, statusCode: 200, data: [.get: injectedMockData])
        }
        
        let expectation = self.expectation(description: "Data request should succeed")
        
        let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: Data()])
        mock.register()
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, urlresponse, err) in
            
            XCTAssertEqual(data, injectedMockData, "Data from injected mock not present")
            XCTAssertNotNil(urlresponse)
            XCTAssertNil(err)
            
            expectation.fulfill()
        }.resume()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    /// `onMockFor` returning nil for non-matching replacement mock shouldn't change previous behavior
    func testOnMockForReplacementReturnsNil() {
        let url = URL(string: "https://www.fakeurl.com")!
        let mockData = "{\"key\":\"value\"}".data(using: .utf8)!
        
        Mocker.onMockFor = { (request: URLRequest) -> Mock? in
            return nil
        }
        
        let expectation = self.expectation(description: "Data request should succeed")
        
        let mock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: mockData])
        mock.register()
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, urlresponse, err) in
            
            XCTAssertEqual(data, mockData, "Data from mock not present")
            XCTAssertNotNil(urlresponse)
            XCTAssertNil(err)
            
            expectation.fulfill()
        }.resume()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    /// `onMockFor` can change the Mock used for a url for subsequent fetches during same test
    func testOnMockForConditionalReplacement() {
        var problemFixed = false    // imaginary problem flag
        
        let url = URL(string: "https://www.fakeurl.com/url1")!
        let goodMockData = "good".data(using: .utf8)!
        
        let failingMock = Mock(url: url, dataType: .json, statusCode: 401, data: [.get: Data()])
        failingMock.register()
        
        let succeedingMock = Mock(url: url, dataType: .json, statusCode: 200, data: [.get: goodMockData])
        // succeedingMock.register() - Do NOT call now as will replace failingMock.
        // Instead, return `succeedingMock` using new `onMockFor` handler if problem is fixed:
        
        Mocker.onMockFor = { _ in
            if problemFixed {
                return succeedingMock
            } else { return nil }
        }
        
        let expectFailure = expectation(description: "call url - should get error")
        
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, urlresponse, err) in
            XCTAssertNotNil(data)
            XCTAssert((urlresponse as? HTTPURLResponse)?.statusCode == 401)
            XCTAssertNil(err)
            
            problemFixed = true         // Imagine problem was handled internally by library that
                                        // then retries automatically (next call to same url)
            expectFailure.fulfill()
        }.resume()
        
        // Wait to call second "retry" fetch until first one returns.
        wait(for: [expectFailure], timeout: 2.0)
        
        let expectSuccess = expectation(description: "call url again - should succeed")
        
        // This retry should succeed becuase problemFixed is now true
        URLSession.shared.dataTask(with: URLRequest(url: url)) { (data, urlresponse, err) in
            XCTAssertEqual(data, goodMockData)
            XCTAssertNotNil(urlresponse)
            XCTAssertNil(err)
            
            expectSuccess.fulfill()
        }.resume()
        
        wait(for: [expectSuccess], timeout: 2.0)
    }
}
