//
//  Validated+Map.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

extension Validated {
    public func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
        return { validated in
            switch validated {
            case let .valid(a):
                return .valid(f(a))
            case let .invalid(e):
                return .invalid(e)
            }
        }
    }
}

public func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
    return { validated in
        switch validated {
        case let .valid(a):
            return .valid(f(a))
        case let .invalid(e):
            return .invalid(e)
        }
    }
}

public func map<A, B>(_ f: @escaping (A) -> B) -> (Parallel<A>) -> Parallel<B> {
    return { f3 in
        return Parallel { callback in
            f3.run { callback(f($0)) }
        }
    }
}
