//
//  Func+Zip.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

public func zip<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
    return Func<R, (A, B)> { r in
        return (r2a.apply(r), r2b.apply(r))
    }
}

public func zip<A, B, C, R>(
    _ r2a: Func<R, A>,
    _ r2b: Func<R, B>,
    _ r2c: Func<R, C>
) -> Func<R, (A, B, C)> {
    return zip(r2a, zip(r2b, r2c)) |> map { ($0, $1.0, $1.1) }
}

public func zip<A, B, C, D, R>(
    with f: @escaping (A, B, C) -> D
) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {
    return { zip($0, $1, $2) |> map(f) }
}

public func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
    return Func<R, (A, B)> { r in
        (r2a.apply(r), r2b.apply(r))
    }
}

public func zip3<A, B, C, R>(
    _ r2a: Func<R, A>,
    _ r2b: Func<R, B>,
    _ r2c: Func<R, C>
) -> Func<R, (A, B, C)> {
    
    return zip2(r2a, zip2(r2b, r2c)) |> map { ($0, $1.0, $1.1) }
}

public func zip2<A, B, C, R>(
    with f: @escaping (A, B) -> C
) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {
    
    return { zip2($0, $1) |> map(f) }
}

public func zip3<A, B, C, D, R>(
    with f: @escaping (A, B, C) -> D
) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {
    
    return { zip3($0, $1, $2) |> map(f) }
}
