//
//  Lenses+KeyPath.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 05/08/2020.
//

import Foundation


/// lens is a functional getter and setter:  in this context the word “functional” really means “immutable”
/// - Parameter keyPath: A key path.
/// - Returns:           A part.
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

/// Infix operator of the `set` function.
/// - Parameters:
///   - keyPath: A key path.
///   - part: A part.
/// - Returns: A function that transforms a whole into a new whole with a part replaced.
///            Usage: let newUser = lens(\User.id).set(0, user)
public func *~ <Whole, Part> (keyPath: WritableKeyPath<Whole, Part>, part: Part) -> ((Whole) -> Whole) {
    return lens(keyPath) *~ part
}

public func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: kp]
    }
}

prefix operator ^

/// Infix operator of the `get` function.
/// - Parameters:
///   - keyPath: A key path.
///   - part: A part.
/// - Returns: A function that transforms a whole into a new whole with a part replaced.
///            Usage: let id = lens(\User.id).get(user)
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
