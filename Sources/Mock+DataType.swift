//
//  Mock+DataType.swift
//  Mocker
//
//  Created by Weiß, Alexander on 26.07.22.
//  Copyright © 2022 WeTransfer. All rights reserved.
//

import Foundation

extension Mock {
    /// The types of content of a request. Will be used as Content-Type header inside a `Mock`.
    public struct DataType {

        /// Name of the data type
        public let name: String


        /// The header value of the data type
        public let headerValue: String

        public init(name: String, headerValue: String) {
            self.name = name
            self.headerValue = headerValue
        }
    }
}

extension Mock.DataType {
    public static var json = Mock.DataType(name: "json", headerValue: "application/json; charset=utf-8")
    public static var html = Mock.DataType(name: "html", headerValue: "text/html; charset=utf-8")
    public static var imagePNG = Mock.DataType(name: "imagePNG",headerValue: "image/png")
    public static var pdf = Mock.DataType(name: "pdf",headerValue: "application/pdf")
    public static var mp4 = Mock.DataType(name: "mp4",headerValue: "video/mp4")
    public static var zip = Mock.DataType(name: "zip",headerValue: "application/zip")
}
