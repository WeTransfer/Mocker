//
//  MockedData.swift
//  Mocker
//
//  Created by Antoine van der Lee on 11/08/2017.
//  Copyright © 2017 WeTransfer. All rights reserved.
//

import Foundation
import UIKit
/// Coyote Test Resources
final class TestResources {
    private static let bundle = Bundle(for: TestResources.self)
    static var sampleFiles = SampleFiles(bundle: bundle)
    static var mockedData = MockedData(bundle: bundle, sampleFiles: TestResources.sampleFiles)
}

/// Contains all available samples files to be used inside tests.
public struct SampleFiles {
    public typealias FileURL = URL
    
    private let bundle: Bundle
    
    /// Initialises a new instance containing access to all sample files.
    ///
    /// - Parameter bundle: The bundle to read the files from.
    public init(bundle: Bundle) {
        self.bundle = bundle
    }
    
    public lazy var botAvatarImageFileUrl: FileURL = self.bundle.url(forResource: "wetransfer_bot_avater", withExtension: "png")!
}


/// Contains all available Mocket
public struct MockedData {
    
    private let bundle: Bundle
    private var sampleFiles: SampleFiles
    
    public var json: JSONSampleData
    
    /// Initialised a new instance to access all available Mocked Data.
    ///
    /// - Parameters:
    ///   - bundle: The bundle to read the files from.
    ///   - sampleFiles: The struct containing access to all Sample Files. Will sometimes be used to return sample files as mocked data.
    public init(bundle: Bundle, sampleFiles: SampleFiles) {
        self.bundle = bundle
        self.sampleFiles = sampleFiles
        self.json = JSONSampleData(bundle: bundle)
    }
    
    public lazy var botAvatarImageResponseHead: Data = self.bundle.url(forResource: "Resources/Responses/bot-avatar-image-head", withExtension: "data")!.data
    public lazy var botAvatarImageResponseGet: Data = self.sampleFiles.botAvatarImageFileUrl.data
    
    public struct JSONSampleData {
        private let bundle: Bundle
        
        fileprivate init(bundle: Bundle) {
            self.bundle = bundle
        }
        
        public lazy var authorize: URL = self.bundle.url(forResource: "MockedData/Requests/authorize", withExtension: "json")!
    }
}

internal extension URL {
    /// Returns a `Data` representation of the current `URL`. Force unwrapping as it's only used for tests.
    var data: Data {
        return try! Data(contentsOf: self)
    }
}
