//
//  MockTests.swift
//
//
//  Created by Antoine van der Lee on 21/04/2021.
//

import Foundation
import XCTest
@testable import Mocker

final class MockTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Mocker.mode = .optout
    }

    override func tearDown() {
        Mocker.removeAll()
        Mocker.mode = .optout
        super.tearDown()
    }

    /// It should match two file extension mocks correctly.
    func testFileExtensionMocksComparing() {
        let mock200 = Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 200, data: [.put: Data()])
        let secondMock200 = Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 200, data: [.put: Data()])
        let mock400 = Mock(fileExtensions: "png", contentType: .imagePNG, statusCode: 400, data: [.put: Data()])
        let mockJPEG = Mock(fileExtensions: "jpeg", contentType: .imagePNG, statusCode: 200, data: [.put: Data()])

        XCTAssertEqual(mock200, secondMock200)
        XCTAssertEqual(mock200, mock400)
        XCTAssertNotEqual(mock200, mockJPEG)
    }
}
