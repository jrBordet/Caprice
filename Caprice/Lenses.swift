//
//  Lenses.swift
//  
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

public struct LensLaw<A, B> {
    static func setGet<A, B>(
        _ lens: Lens<A,B>,
        _ whole: A,
        _ part: B
    ) -> Bool where B: Equatable {
        lens.get(lens.set(part, whole)) == part
    }
}

/**
 Lens
 - parameter A: a Whole.
 - parameter B: a Part.
 */

public struct Lens <A, B> {
    let get: (A) -> B
    let set: (B, A) -> A
    
    public init(
        get: @escaping(A) -> B,
        set: @escaping (B, A) -> A) {
        self.get = get
        self.set = set
    }
    
    /**
     Map a function over a part of a whole.
     - parameter f: A function.
     - returns: A function that takes wholes to wholes by applying the function to a subpart.
     */
    public func over(_ f: @escaping (B) -> B) -> ((A) -> A) {
        return { a in
            let b = self.get(a)
            return self.set(f(b), a)
        }
    }
}

/// The zip function, that mixes together two lenses with the same whole part, so we can apply both at the same time, by retrieving/modifying two things together.
/// - Parameters:
///   - lhs: a Lens<Whole, Part>
///   - rhs: a Lens<Whole, AnotherPart>
/// - Returns: a Lens<Whole, (Part, AnotherPart)>
public func zip<A, B, C>(
    _ lhs: Lens<A, B>,
    _ rhs: Lens<A, C>
) -> Lens<A, (B, C)> {
    Lens<A, (B, C)>(
        get: {
            (lhs.get($0), rhs.get($0))
    }, set: { (parts, whole) -> A in
        let partialWhole = lhs.set(parts.0, whole)
        return rhs.set(parts.1, partialWhole)
    })
}

public func zip2<A, B, C, D>(
    _ first: Lens<A, B>,
    _ second: Lens<A, C>,
    _ third: Lens<A, D>
) -> Lens<A, (B, (C, D))> {
    Lens<A, (B, (C, D))>(
        get: { whole -> (B, (C, D)) in
            zip(first, zip(second, third)).get(whole)
    }, set: { (parts, whole) -> A in
        zip(first, zip(second, third)).set(parts, whole)
    })
}

public func zip3<A, B, C, D, E>(
    _ first: Lens<A, B>,
    _ second: Lens<A, C>,
    _ third: Lens<A, D>,
    _ fourth: Lens<A, E>
) -> Lens<A, (B, (C, (D, E)))> {
    Lens<A, (B, (C, (D, E)))>(
        get: { whole -> (B, (C, (D, E))) in
            zip(first, zip2(second, third, fourth)).get(whole)
    }, set: { (parts, whole) -> A in
        zip(first, zip2(second, third, fourth)).set(parts, whole)
    })
}
