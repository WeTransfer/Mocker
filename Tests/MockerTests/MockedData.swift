//
//  MockedData.swift
//  Mocker
//
//  Created by Antoine van der Lee on 11/08/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import Foundation

/// Contains all available Mocked data.
public final class MockedData {
    public static let botAvatarImageFileUrl: URL = Bundle.module.url(forResource: "wetransfer_bot_avatar", withExtension: "png")!
    public static let exampleJSON: URL = Bundle.module.url(forResource: "example", withExtension: "json")!
    public static let redirectGET: URL = Bundle.module.url(forResource: "sample-redirect-get", withExtension: "data")!
}

extension Bundle {
#if !SWIFT_PACKAGE
    static let module = Bundle(for: MockedData.self)
#endif
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
