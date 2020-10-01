//
//  Functors.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

// flatMap: ([A], (A) -> [B]) -> [B]

/**
 A functor is a type that carries with it a map-like function.
 
 So, we think it’s helpful to eschew any overly intuitive description of functor and instead rely only on it’s most basic property: the fact that it has a map function, and that the map function must satisfy the property that map(id) == id. And then from that we get to derive the wonderful property that map preserves function composition, i.e. map(f >>> g) == map(f) >>> map(g).
 */

public struct Func<A, B> {
    public let apply: (A) -> B
    
    public init (_ apply: @escaping(A) -> B) {
        self.apply = apply
    }
    
    public func flatMap<C>(_ f: @escaping (B) -> Func<A, C>) -> Func<A, C> {
        return Func<A, C> { a -> C in
            //  let b = self.apply(a)
            //  let funcAC = b |> f // Func<A, C>
            //  funcAC.apply(a)
            
            f(self.apply(a)).apply(a)
        }
    }
}

public struct Predicate<A> {
    public let contains: (A) -> Bool
    
    public init(contains: @escaping(A) -> Bool) {
        self.contains = contains
    }
    
    public func flatMap<B>(_ transform: @escaping(B) -> Predicate<B>) -> Predicate<B> {
        return Predicate<B> { b -> Bool in
            transform(b).contains(b)
        }
    }
    
}

extension Predicate {
    public func contramap<B>(_ f: @escaping (B) -> A) -> Predicate<B> {
        return Predicate<B>(contains: f >>> self.contains)
    }
}

extension Result {
    public func contramap<A, B, E>(_ f: @escaping(B) -> A) -> Result<B, E> {
        fatalError()
    }
}

public enum Validated<Value, Error> {
    case valid(Value)
    case invalid([Error])
    
    func flatMap<B>(_ transform: (Value) -> Validated<B, [Error]>) -> Validated<B, [Error]> {
        switch self {
        case let .valid(value):
            return transform(value)
        case let .invalid(error):
            return .invalid([error])
        }
    }
}

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
    
    public func flatMap<B>(_ f: @escaping (A) -> Parallel<B>) -> Parallel<B> {
        return Parallel<B> { callback in
//            self.run { a in
//                let parallelB = f(a)
//
//                parallelB.run { b in
//                    callback(b)
//                }
//            }
            self.run { a in
                callback |> f(a).run
            }
        }
    }
}

extension Parallel {
    public func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
        return Parallel<B> { callback in
            self.run { a in callback(f(a)) }
        }
    }
}

/// let aDelayedInt = delay(by: 3).map { 42 }
/// - Parameters:
///   - duration: a TimeInterval
///   - line:
/// - Returns: Parallel <Void>
public func delay(by duration: TimeInterval, line: UInt = #line) -> Parallel<Void> {
    return Parallel { callback in
        print("Delaying line \(line) by \(duration)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            callback(())
            print("Executed line \(line)")
        }
    }
}
