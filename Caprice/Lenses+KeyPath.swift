//
//  Lenses+KeyPath.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 05/08/2020.
//

import Foundation


/// lens is a functional getter and setter:  in this context the word “functional” really means “immutable”.
/// - Parameters:
///   - keyPath: A key path.
///   - part: A part.
/// - Returns: A lens.
///     ```
///     let id = lens(\User.id).get(user)
///     let newUser = lens(\User.id).set(0, user)
///     ```
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
///     ```
///     user |> \.email *~ "another@mail.com"
///     ```
public func *~ <Whole, Part> (keyPath: WritableKeyPath<Whole, Part>, part: Part) -> ((Whole) -> Whole) {
    return lens(keyPath) *~ part
}

/// `get` function.
/// - Parameter kp: A key path.
/// - Returns: A function taht take a part from a Whole.
///     ```
///     let id = lens(\User.id).get(user)
///     ```
public func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    return { root in
        root[keyPath: kp]
    }
}

/// Infix operator of the `get` function.
/// - Parameters:
///   - keyPath: A key path.
///   - part: A part.
/// - Returns: A function taht take a part from a Whole.
///   A loop to print each character on a seperate line
///    ```
///    let name = book |> ^\Book.author.name
///    ```
prefix operator ^

public prefix func ^<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
    get(kp)
}

// users.filter(by(^\User.id, 1))


/// A function to descriibe a way to filter
/// - Parameters:
///   - f: A function that take the Whole and return a Part
///   - x: A value Equatable to match
/// - Returns: A function that take a whole and return a boolean.
///     ```
///     books.filter(by(^\Book.author.name, "Massimo"))
///     ```
public func by<Root, Value: Equatable>(
    _ f: @escaping (Root) -> Value,
    _ x: Value
) -> (Root) -> Bool {
    return { $0 |> f == x }
}


/// A function to descriibe a way to sort.
/// - Parameters:
///   - f: A function that take the Whole and return a Part
///   - g: A Value
/// - Returns: A function that take a whole and return a function that take two value of the same type and return a boolean..
///     ```
///     users.sorted(by: their(^\User.id, <))
///     users.min(by: their(get(\.email), <))
///     users.max(by: their(get(\.email), <))
///     ```
public func their<Root, Value>(
    _ f: @escaping (Root) -> Value,
    _ g: @escaping (Value, Value) -> Bool
) -> (Root, Root) -> Bool {
    return { g(f($0), f($1)) }
}

/**
 It’s admittedly a bit strange to specify ' <'given that it’s the only valid way of getting the maximum or minimum.
 Maybe we can define an overload to help.
 
 ```
 users.min(by: their(get(\.email), <))
 
 users.max(by: their(get(\.email), <))
 ```
 */

public func their<Root, Value: Comparable>(
    _ f: @escaping (Root) -> Value
) -> (Root, Root)-> Bool {
    return their(f, <)
}

/// A function to descriibe a  way to reduce.
/// - Parameters:
///   - f: A function that take the Whole and return a Part
///   - g: A Value
/// - Returns: A function that take a whole and return a function that take a Part and  a Whole and return a Value.
///     ```
///     _ = episodes.reduce(0, combining(^\.viewCount, by: +))
///     ```
func combining<Root, Value>(
    _ f: @escaping (Root) -> Value,
    by g: @escaping (Value, Value) -> Value
) -> (Value, Root) -> Value {
    return { value, root in
        g(value, f(root))
    }
}
