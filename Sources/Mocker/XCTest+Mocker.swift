//
//  XCTest+Mocker.swift
//  Mocker
//
//  Created by Antoine van der Lee on 27/05/2020.
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import Foundation
import XCTest

public extension XCTestCase {
    func expectationForRequestingMock(_ mock: inout Mock) -> XCTestExpectation {
        let mockExpectation = expectation(description: "\(mock) should be requested")
        mock.onRequestExpectation = mockExpectation
        return mockExpectation
    }

    func expectationForCompletingMock(_ mock: inout Mock) -> XCTestExpectation {
        let mockExpectation = expectation(description: "\(mock) should be finishing")
        mock.onCompletedExpectation = mockExpectation
        return mockExpectation
    }
}
