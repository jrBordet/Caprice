//
//  Parallel+Zip.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

public func zip2<A, B>(_ fa: Parallel<A>, _ fb: Parallel<B>) -> Parallel<(A, B)> {
    return Parallel<(A, B)> { callback in
        var a: A?
        var b: B?
        fa.run {
            a = $0
            if let b = b { callback(($0, b)) }
        }
        fb.run {
            b = $0
            if let a = a { callback((a, $0)) }
        }
    }
}

public func zip2<A, B, C>(
    with f: @escaping (A, B) -> C
) -> (Parallel<A>, Parallel<B>) -> Parallel<C> {
    
    return { zip2($0, $1) |> map(f) }
}

public func zip3<A, B, C>(_ fa: Parallel<A>, _ fb: Parallel<B>, _ fc: Parallel<C>) -> Parallel<(A, B, C)> {
    return zip2(fa, zip2(fb, fc)) |> map { ($0, $1.0, $1.1) }
}

public func zip3<A, B, C, D>(
    with f: @escaping (A, B, C) -> D
) -> (Parallel<A>, Parallel<B>, Parallel<C>) -> Parallel<D> {
    return { zip3($0, $1, $2) |> map(f) }
}
