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
        
        URLSession.shared.dataTask(with: mock.url) { (_, response, error) in
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
        
        URLSession.shared.dataTask(with: mock.url) { (_, response, error) in
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
    func testDelayedMock() {
        let expectation = self.expectation(description: "Data request should be cancelled")
        var mock = Mock(dataType: .json, statusCode: 200, data: [.get: Data()])
        mock.delay = DispatchTimeInterval.seconds(5)
        mock.register()
        
        let task = URLSession.shared.dataTask(with: mock.url) { (_, _, error) in
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
    
    func testComposedURLMatch() {
        let composedURL = URL(fileURLWithPath: "resource", relativeTo: URL(string: "https://host.com/api/"))
        let simpleURL = URL(string: "https://host.com/api/resource")
        let mock = Mock(url: composedURL, dataType: .json, statusCode: 200, data: [.get: MockedData.exampleJSON.data])
        if let url = simpleURL {
            let urlRequest = URLRequest(url: url)
            XCTAssertEqual(composedURL.absoluteString, url.absoluteString)
            XCTAssert(mock == urlRequest)
        } else {
            XCTFail("Unable to create simpleURL")
        }
        
    }
}
