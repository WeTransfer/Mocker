//
//  DynamicMocksTests.swift
//  MockerTests
//
//  Copyright © 2020 WeTransfer. All rights reserved.
//

@testable import Mocker
import XCTest

class DynamicMocksTests: XCTestCase {
    override func setUpWithError() throws {
        // make sure this is cleared before each test to avoid bleed-over between tests.
        Mocker.onMockFor = nil
    }

    /// It should call `onMockFor` to change the mock used for a url for subsequent fetches during the same test
    func testOnMockForConditionalReplacement() {
        let service = FakeService() // the service we are testing

        // Create Mock data
        let goodMockData = "{\"name\":\"Joe Jones\"}".data(using: .utf8)!
        let goodTokenData = "{\"token\":\"good token\"}".data(using: .utf8)!

        // Create our three Mocks:

        let failingProfileMock = Mock(url: FakeService.FakeServiceURLs.profileURL,
                                      dataType: .json,
                                      statusCode: 401,
                                      data: [.get: Data()])
        failingProfileMock.register()

        let succeedingProfileMock = Mock(url: FakeService.FakeServiceURLs.profileURL,
                                         dataType: .json,
                                         statusCode: 200,
                                         data: [.get: goodMockData])
        // succeedingMock.register() - Do NOT call now as will replace failingMock.
        // Instead, return `succeedingMock` using new `onMockFor` handler if problem is fixed:

        let refreshTokenMock = Mock(url: FakeService.FakeServiceURLs.refreshTokenURL,
                                    dataType: .json,
                                    statusCode: 200,
                                    data: [.get: goodTokenData])
        refreshTokenMock.register()

        // Now set up our dynamic mock that will replace the failingProfileMock
        // with the succeedingProfileMock IFF we have a valid token (if the refreshToken call is made
        // and gets a valid token)

        Mocker.onMockFor = { _ in
            if FakeService.accessToken.token == "good token" {
                return succeedingProfileMock
            } else { return nil }
        }

        let expectFailure = expectation(description: "call url - should get error")

        // Now make the profile call that we expect will fail, internally
        // get a new token from the service, and then retry and finally return us valid profile data.
        service.profile(for: "JJ") { profile, error in
            XCTAssertNil(error)
            XCTAssertNotNil(profile)
            XCTAssertEqual(profile!.name, "Joe Jones")
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 2.0)
    }

    func FAILS_testOnMockForConditionalReplacementAvdLeeSuggestion1() {
        let service = FakeService() // the service we are testing

        // Create Mock data
        let goodMockData = "{\"name\":\"Joe Jones\"}".data(using: .utf8)!
        let goodTokenData = "{\"token\":\"good token\"}".data(using: .utf8)!

        // Create our three Mocks:

        let succeedingProfileMock = Mock(url: FakeService.FakeServiceURLs.profileURL,
                                         dataType: .json,
                                         statusCode: 200,
                                         data: [.get: goodMockData])
        // succeedingMock.register() - Do NOT call now as will get replaced by failingMock.
        // Instead, try registering it in the `onRequest` handler for failingProfileMock
        // if the token has been updated

        var failingProfileMock = Mock(url: FakeService.FakeServiceURLs.profileURL,
                                      dataType: .json,
                                      statusCode: 401,
                                      data: [.get: Data()])

        failingProfileMock.onRequest = { _, _ in
            // this won't help because it's too late.
            if FakeService.accessToken.token == "good token" {
                succeedingProfileMock.register()
            }
        }
        failingProfileMock.register()

        let refreshTokenMock = Mock(url: FakeService.FakeServiceURLs.refreshTokenURL,
                                    dataType: .json,
                                    statusCode: 200,
                                    data: [.get: goodTokenData])
        refreshTokenMock.register()

        // Now set up our dynamic mock that will replace the failingProfileMock
        // with the succeedingProfileMock IFF we have a valid token (if the refreshToken call is made
        // and gets a valid token)

        //        Mocker.onMockFor = { _ in
        //            if FakeService.accessToken.token == "good token" {
        //                return succeedingProfileMock
        //            } else { return nil }
        //        }

        let expectFailure = expectation(description: "call url - should get error")

        // Now make the profile call that we expect will fail, internally
        // get a new token from the service, and then retry and finally return us valid profile data.
        service.profile(for: "JJ") { profile, error in
            XCTAssertNil(error, "error is not nil!")
            XCTAssertNotNil(profile, "profile is nil")
            XCTAssertEqual(profile?.name, "Joe Jones", "profile name doesn't match")
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 2.0)
    }

    func FAILS_testOnMockForConditionalReplacementAvdLeeSuggestion2() {
        let service = FakeService() // the service we are testing

        // Create Mock data
        let goodMockData = "{\"name\":\"Joe Jones\"}".data(using: .utf8)!
        let goodTokenData = "{\"token\":\"good token\"}".data(using: .utf8)!

        // Create our three Mocks:

        let succeedingProfileMock = Mock(url: FakeService.FakeServiceURLs.profileURL,
                                         dataType: .json,
                                         statusCode: 200,
                                         data: [.get: goodMockData])
        // succeedingMock.register() - Do NOT call now as will get replaced by failingMock.
        // Instead, try registering it in the `onRequest` handler for failingProfileMock
        // if the token has been updated

        let failingProfileMock = Mock(url: FakeService.FakeServiceURLs.profileURL,
                                      dataType: .json,
                                      statusCode: 401,
                                      data: [.get: Data()])
        failingProfileMock.register()

        var refreshTokenMock = Mock(url: FakeService.FakeServiceURLs.refreshTokenURL,
                                    dataType: .json,
                                    statusCode: 200,
                                    data: [.get: goodTokenData])

        refreshTokenMock.onRequest = { _, _ in
            // This won't help because it's too early.
            // Removing the if-test means we are *assuming* that the refresh payload
            // processing code worked, but that's part of the code under test so
            // we do not want to do that.
            if FakeService.accessToken.token == "good token" {
                succeedingProfileMock.register()
            }
        }

        refreshTokenMock.register()

        // Now set up our dynamic mock that will replace the failingProfileMock
        // with the succeedingProfileMock IFF we have a valid token (if the refreshToken call is made
        // and gets a valid token)

        //        Mocker.onMockFor = { _ in
        //            if FakeService.accessToken.token == "good token" {
        //                return succeedingProfileMock
        //            } else { return nil }
        //        }

        let expectFailure = expectation(description: "call url - should get error")

        // Now make the profile call that we expect will fail, internally
        // get a new token from the service, and then retry and finally return us valid profile data.
        service.profile(for: "JJ") { profile, error in
            XCTAssertNil(error, "error is not nil!")
            XCTAssertNotNil(profile, "profile is nil")
            XCTAssertEqual(profile?.name, "Joe Jones", "profile name doesn't match")
            expectFailure.fulfill()
        }

        wait(for: [expectFailure], timeout: 2.0)
    }
}

// MARK: - Example Service Under Test -

// This code is NOT in a test file in a real project and so
// CANNOT have any XCTestXXX or Expectations or anything in it.

// This is a simplified version of the type of thing Dynamic Mocks will let you test.
// This code would normally be somewhere in your app, significantly more complex, and
// something you really need to write robust tests on.

// This represents a service doing the fairly standard work of fetching a user profile, say.
// As with most systems, an Access Token is required for access (imagine it's placed in an Authorization header).
// If the token expires then a differnet API call must be made to fetch a refreshed token.

class FakeService {
    static var accessToken = Token(token: "bad token")  // this will actualy be in the keychain or similar

    struct FakeServiceURLs {
        static let profileURL = URL(string: "http://fakeservice.com/profile")!
        static let refreshTokenURL = URL(string: "http://fakeservice.com/token/refresh")!
    }

    enum FakeServiceErrors: Error {
        case urlError(URLError)
        case badResponse
        case tokenError // unrecoverable token error
        // ...
        case unknownError
    }

    struct Profile: Decodable {
        var name: String
        // ...
    }

    struct Token: Decodable {
        var token: String
    }

    func profile(for userID: String, retrying: Bool = false, _ completion: @escaping (Profile?, Error?) -> Void) {
        // pretend the `accessToken` is used here by the service (put in Authorization header or something)
        URLSession.shared.dataTask(with: URLRequest(url: FakeServiceURLs.profileURL)) { data, urlResponse, err in
            guard err == nil else {
                completion(nil, err!)
                return
            }
            if let httpResponse = urlResponse as? HTTPURLResponse {
                if httpResponse.statusCode == 200,
                    let profileData = data {
                    // return the successful Profile since we succeeded
                    do {
                        let profile = try JSONDecoder().decode(Profile.self, from: profileData)
                        completion(profile, nil)
                    } catch {
                        completion(nil, error)
                    }
                } else if httpResponse.statusCode == 401, !retrying { // only try token fetch once (recursion limiter)
                    //
                    // we have to fetch a new token (say) via asynchronous service call
                    self.refreshToken(for: userID) { token, err in
                        if let token = token {
                            FakeService.accessToken = token     // not thread safe and totally insecure; just a mock
                            // recurse to try again; again, not how I'd normally do this, but adequate.
                            // Set retrying flag so don't recurse more than once, and pass caller's original completion handler
                            self.profile(for: userID, retrying: true, completion)
                        } else if let error = err {
                            print("failed to get a new token: \(error)")
                            completion(nil, FakeServiceErrors.tokenError)
                        } else {
                            // return unknown error
                            completion(nil, FakeServiceErrors.unknownError)
                        }
                    }
                } else {
                    completion(nil, FakeServiceErrors.urlError(URLError(URLError.Code(rawValue: httpResponse.statusCode))))
                }
            } else {
                completion(nil, FakeServiceErrors.badResponse)
            }
        }.resume()
    }

    func refreshToken(for userID: String, _ completion: @escaping (Token?, Error?) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: FakeServiceURLs.refreshTokenURL)) { data, urlResponse, _ in
            // since we are mocking this and know it'll return 200, simplify this for the same of this example.
            if let httpResponse = urlResponse as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let tokenData = data {
                do {
                    let token = try JSONDecoder().decode(Token.self, from: tokenData)
                    completion(token, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, FakeServiceErrors.tokenError)
            }

        }.resume()
    }
}
