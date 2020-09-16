//
//  Func+Map.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import Foundation

public func map<A, B, R>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
    return { r2a in
        return Func { r in
            f(r2a.apply(r))
        }
    }
}
