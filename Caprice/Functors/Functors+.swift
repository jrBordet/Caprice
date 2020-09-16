//
//  Functors.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

public struct Func<R, A> {
    public let apply: (R) -> A
    
    public init (_ apply: @escaping(R) -> A) {
        self.apply = apply
    }
}

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

/**
 A functor is a type that carries with it a map-like function.
 
 So, we think it’s helpful to eschew any overly intuitive description of functor and instead rely only on it’s most basic property: the fact that it has a map function, and that the map function must satisfy the property that map(id) == id. And then from that we get to derive the wonderful property that map preserves function composition, i.e. map(f >>> g) == map(f) >>> map(g).
 */

public struct F1<A: Equatable>: Equatable {
    public static func == (lhs: F1<A>, rhs: F1<A>) -> Bool {
        lhs.value == rhs.value
    }
    
    public let value: A
    
    public init(value: A) {
        self.value = value
    }
}

public struct F2<A, B> {
    public let apply: (A) -> B
    
    public init(apply: @escaping(A) -> B) {
        self.apply = apply
    }
}

public struct Parallel<A> {
    public let run: (@escaping (A) -> Void) -> Void
    
    public init(_ run: @escaping (@escaping (A) -> Void) -> Void) {
        self.run = run
    }
}
