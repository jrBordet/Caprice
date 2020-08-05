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

// MARK: - KeyPath lenses

public func lens<Whole, Part>(_ keyPath: WritableKeyPath<Whole, Part>) -> Lens<Whole, Part> {
    return Lens<Whole, Part>(
        get: { $0[keyPath: keyPath] },
        set: { part, whole in
            var copy = whole
            copy[keyPath: keyPath] = part
            return copy
    }
    )
}

/**
 Infix operator of the `set` function.
 - parameter keyPath: A key path.
 - parameter part:    A part.
 - returns: A function that transforms a whole into a new whole with a part replaced.
 */
public func *~ <Whole, Part> (keyPath: WritableKeyPath<Whole, Part>, part: Part) -> ((Whole) -> Whole) {
    return lens(keyPath) *~ part
}

// MARK: - KeyPath get

public func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: kp]
    }
}

prefix operator ^

public prefix func ^<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    get(kp)
}

// users.filter(by(^\User.id, 1))

public func by<Root, Value: Equatable>(
    _ f: @escaping (Root) -> Value,
    _ x: Value
) -> (Root) -> Bool {
    return { $0 |> f == x }
}

public func their<Root, Value>(
    _ f: @escaping (Root) -> Value,
    _ g: @escaping (Value, Value) -> Bool
) -> (Root, Root) -> Bool {
    return { g(f($0), f($1)) }
}

/**
 It’s admittedly a bit strange to specify ' <'given that it’s the only valid way of getting the maximum or minimum.
 Maybe we can define an overload to help.
 
 users
 .min(by: their(get(\.email), <))
 
 users
 .max(by: their(get(\.email), <))
 
 */

public func their<Root, Value: Comparable>(
    _ f: @escaping (Root) -> Value
) -> (Root, Root)-> Bool {
    return their(f, <)
}

// _ = episodes.reduce(0, combining(^\.viewCount, by: +))

func combining<Root, Value>(
    _ f: @escaping (Root) -> Value,
    by g: @escaping (Value, Value) -> Value
) -> (Value, Root) -> Value {
    return { value, root in
        g(value, f(root))
    }
}


extension Sequence {
    public func map<Value>(_ kp: KeyPath<Element, Value>) -> [Value] {
        self.map { $0[keyPath: kp] }
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
