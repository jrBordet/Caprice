//
//  Lenses.swift
//  
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

public struct Lens <A, B> {
    let get: (A) -> B
    let set: (B, A) -> A
    
    public init(
        get: @escaping(A) -> B,
        set: @escaping (B, A) -> A) {
        self.get = get
        self.set = set
    }
}

//public func compose <A, B, C> (_ lhs: Lens<A, B>, _ rhs: Lens<B, C>) -> Lens<A, C> {
//    Lens<A, C>(
//        get: { a in rhs.get(lhs.get(a)) },
//        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
//    )
//}
//
//public func * <A, B, C> (_ lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
//    return compose(lhs, rhs)
//}
