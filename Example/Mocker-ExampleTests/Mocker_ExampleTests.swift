//
//  Mocker_ExampleTests.swift
//  Mocker-ExampleTests
//
//  Created by Antoine van der Lee on 11/08/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import XCTest
import Mocker

final class Mocker_ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
//        Mock(dataType: <#T##Mock.DataType#>, statusCode: <#T##Int#>, data: <#T##[Mock.HTTPMethod : Data]#>)
//        Mock(url: <#T##URL?#>, dataType: <#T##Mock.DataType#>, statusCode: <#T##Int#>, data: <#T##[Mock.HTTPMethod : Data]#>, additionalHeaders: <#T##[String : String]#>, fileExtensions: <#T##[String]?#>)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMockedDataRequest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
