//
//  ForwardApplication.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

infix operator |>: ForwardApplication

public func |> <A, B> (x: A, f: (A) -> B) -> B {
  return f(x)
}
