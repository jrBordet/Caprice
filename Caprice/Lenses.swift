//
//  Lenses.swift
//  
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

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
