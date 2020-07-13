//
//  ForwardComposition.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

infix operator *~: ForwardComposition

public func *~ <A, B> (lhs: Lens<A, B>, rhs: B) -> (A) -> A {
    return { a in
        lhs.set(rhs, a)
    }
}

prefix operator ^

public prefix func ^ <A, B> (lhs: Lens<A, B>) -> (A) -> B {
    return { a in
        lhs.get(a)
    }
}

infix operator >>>: ForwardComposition

public func >>> <A>(
    f: @escaping (A) -> A,
    g: @escaping (A) -> A) -> (A) -> A {
    return { a in
        g(f(a))
    }
}

public func >>> <A, B, C>(
    f: @escaping (A) -> B,
    g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

public func >>> <A, B, C> (
    _ lhs: Lens<A, B>,
    _ rhs: Lens<B, C>
) -> Lens<A, C> {
    Lens<A, C>(
        get: { a in rhs.get(lhs.get(a)) },
        set: { (c, a) in lhs.set(rhs.set(c, lhs.get(a)), a) }
    )
}
