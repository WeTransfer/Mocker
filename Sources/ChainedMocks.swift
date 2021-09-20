//
//  ChainedMocks.swift
//  Mocker
//
//  Created by Aleksey Kuznetsov on 20.09.2021.
//  Copyright © 2021 WeTransfer. All rights reserved.
//

import Foundation

/// Chained mocks representation which can be used for mocking data requests where
/// order is important or same requests can return different data.
public class ChainedMocks {
    /// The array of mocks.
    var mocks: [Mock]

    /// Creates the chained mocks.
    ///
    /// - Parameters:
    ///   - mocks: The array of mocks.
    public init(_ mocks: [Mock]) {
        self.mocks = mocks
    }

    /// Chains another mock and returns itself.
    public func chain(_ anotherMock: Mock) -> Self {
        mocks.append(anotherMock)
        return self
    }

    /// Registers the chained mocks with the `Mocker`.
    public func register() {
        Mocker.register(self)
    }

    /// Consumes the first element of the chained mocks and returns the next.
    ///
    /// Example: Suppose we have mocks [1, 2, 3], this method will return 2 and the chained mocks will become [2, 3].
    func consume() -> Mock? {
        guard !mocks.isEmpty else { return nil }
        mocks.removeFirst()
        return mocks.first
    }
}
