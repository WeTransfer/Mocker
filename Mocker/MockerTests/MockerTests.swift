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
    
    /// It should returned the register mocked image data as response.
    func testImageURLDataRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://avatars3.githubusercontent.com/u/26250426?v=4&s=400")!
        
        let mock = Mock(url: originalURL, contentType: .imagePNG, statusCode: 200, data: [
            Mock.HTTPMethod.head: TestResources.mockedData.botAvatarImageResponseHead,
            Mock.HTTPMethod.get: TestResources.mockedData.botAvatarImageResponseGet
            ])
        
        mock.register()
        URLSession.shared.dataTask(with: originalURL) { (data, response, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: TestResources.sampleFiles.botAvatarImageFileUrl.path)!
            
            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
        }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    /// It should returned the register mocked image data as response for register file types.
    func testImageExtensionDataRequest() {
        let expectation = self.expectation(description: "Data request should succeed")
        let originalURL = URL(string: "https://www.wetransfer.com/sample-image.png")
        
        Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 200, data: [
            Mock.HTTPMethod.head: TestResources.mockedData.botAvatarImageResponseHead,
            Mock.HTTPMethod.get: TestResources.mockedData.botAvatarImageResponseGet
        ]).register()
        
        URLSession.shared.dataTask(with: originalURL!) { (data, response, error) in
            XCTAssert(error == nil)
            let image: UIImage = UIImage(data: data!)!
            let sampleImage: UIImage = UIImage(contentsOfFile: TestResources.sampleFiles.botAvatarImageFileUrl.path)!
            
            XCTAssert(image.size == sampleImage.size, "Image should be returned mocked")
            expectation.fulfill()
            }.resume()
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}
