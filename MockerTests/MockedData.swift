//
//  MockedData.swift
//  Mocker
//
//  Created by Antoine van der Lee on 11/08/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import Foundation
import UIKit

/// Contains all available Mocked data.
public final class MockedData {
    public static let botAvatarImageFileUrl: URL = Bundle(for: MockedData.self).url(forResource: "wetransfer_bot_avatar", withExtension: "png")!
    public static let exampleJSON: URL = Bundle(for: MockedData.self).url(forResource: "Resources/JSON Files/example", withExtension: "json")!
    public static let anotherExampleJSON: URL = Bundle(for: MockedData.self).url(forResource: "Resources/JSON Files/another-example", withExtension: "json")!
    public static let redirectGET: URL = Bundle(for: MockedData.self).url(forResource: "Resources/sample-redirect-get", withExtension: "data")!
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
