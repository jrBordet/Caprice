//
//  Apply.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation


infix operator <*>: Apply

public func <*><A, B, E>(_ lhs: Result<((A) -> B), E>, rhs: Result<A, E>) -> Result<B, E> {
    switch lhs {
    case let .success(value):
        return rhs.map { value($0) } // Result<B, E>
    case let .failure(error):
        return .failure(error)
    }
}
