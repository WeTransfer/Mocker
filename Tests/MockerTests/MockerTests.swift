import XCTest
@testable import Mocker

final class MockerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Mocker().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
