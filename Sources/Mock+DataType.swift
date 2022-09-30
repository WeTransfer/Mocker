//
//  Mock+DataType.swift
//  Mocker
//
//  Created by Weiß, Alexander on 26.07.22.
//  Copyright © 2022 WeTransfer. All rights reserved.
//

import Foundation

public extension Mock {
    /// The types of content of a request. Will be used as Content-Type header inside a `Mock`.
    struct DataType {
        /// Name of the data type.
        public let name: String

        /// The header value of the data type.
        public let headerValue: String

        public init(name: String, headerValue: String) {
            self.name = name
            self.headerValue = headerValue
        }
    }
}

public extension Mock.DataType {
    static let json = Mock.DataType(name: "json", headerValue: "application/json; charset=utf-8")
    static let html = Mock.DataType(name: "html", headerValue: "text/html; charset=utf-8")
    static let imagePNG = Mock.DataType(name: "imagePNG", headerValue: "image/png")
    static let pdf = Mock.DataType(name: "pdf", headerValue: "application/pdf")
    static let mp4 = Mock.DataType(name: "mp4", headerValue: "video/mp4")
    static let zip = Mock.DataType(name: "zip", headerValue: "application/zip")
}
