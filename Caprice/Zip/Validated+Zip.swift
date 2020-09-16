//
//  Validated+Zip.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

public func zip<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
    switch (a, b) {
    case let (.valid(a), .valid(b)):
        return .valid((a, b))
    case let (.valid, .invalid(e)):
        return .invalid(e)
    case let (.invalid(e), .valid):
        return .invalid(e)
    case let (.invalid(e1), .invalid(e2)):
        return .invalid(e1 + e2)
    }
}

public func zip<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
    switch (a, b) {
    case let (.success(a), .success(b)):
        return .success((a, b))
    case let (.success, .failure(e)):
        return .failure(e)
    case let (.failure(e), .success):
        return .failure(e)
    case let (.failure(e1), .failure(e2)):
        fatalError()
    }
}

public func zip<A, B, C, E>(
    with f: @escaping (A, B) -> C
) -> (Validated<A, E>, Validated<B, E>) -> Validated<C, E> {
    
    return { a, b in
        zip(a, b) |> map(f)
    }
}

public func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
    switch (a, b) {
    case let (.valid(a), .valid(b)):
        return .valid((a, b))
    case let (.valid, .invalid(e)):
        return .invalid(e)
    case let (.invalid(e), .valid):
        return .invalid(e)
    case let (.invalid(e1), .invalid(e2)):
        return .invalid(e1 + e2)
    }
}

public func zip2<A, B, C, E>(
    with f: @escaping (A, B) -> C
) -> (Validated<A, E>, Validated<B, E>) -> Validated<C, E> {
    
    return { zip2($0, $1) |> map(f) }
}

public func zip3<A, B, C, E>(_ a: Validated<A, E>, _ b: Validated<B, E>, _ c: Validated<C, E>) -> Validated<(A, B, C), E> {
    return zip2(a, zip2(b, c))
        |> map { a, bc in (a, bc.0, bc.1) }
}

public func zip3<A, B, C, D, E>(
    with f: @escaping (A, B, C) -> D
) -> (Validated<A, E>, Validated<B, E>, Validated<C, E>) -> Validated<D, E> {
    
    return { zip3($0, $1, $2) |> map(f) }
}

public func compute(_ a: Double, _ b: Double) -> Double {
    return sqrt(a) + sqrt(b)
}

public func compute(_ a: Double...) -> Double {
    return a.reduce(0) { (a, value) -> Double in
        a + sqrt(value)
    }
    
    //return sqrt(a.first!)
}

public func validate(_ a: Double, label: String) -> Validated<Double, String> {
    return a < 0
        ? .invalid(["\(label) must be non-negative"])
        : .valid(a)
}
