//
//  Predicate.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 12/09/2020.
//

import Foundation

public struct Predicate<A> {
    public let contains: (A) -> Bool
    
    public init(contains: @escaping(A) -> Bool) {
        self.contains = contains
    }
}

extension Predicate {
    public func contramap<B>(_ f: @escaping (B) -> A) -> Predicate<B> {
        return Predicate<B>(contains: f >>> self.contains)
    }
}

public enum Validated<Value, Error> {
  case valid(Value)
  case invalid([Error])
}
