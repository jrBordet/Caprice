//
//  FunctorsTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 09/09/2020.
//

import XCTest
import Caprice

/**
 A functor is a type that carries with it a map-like function.
 
 So, we think it’s helpful to eschew any overly intuitive description of functor and instead rely only on it’s most basic property: the fact that it has a map function, and that the map function must satisfy the property that map(id) == id. And then from that we get to derive the wonderful property that map preserves function composition, i.e. map(f >>> g) == map(f) >>> map(g).
 */

struct F1<A: Equatable>: Equatable {
    static func == (lhs: F1<A>, rhs: F1<A>) -> Bool {
        lhs.value == rhs.value
    }
    
    let value: A
}

struct F2<A, B> {
    let apply: (A) -> B
}

struct Parallel<A> {
    let run: (@escaping (A) -> Void) -> Void
}

class FunctorsTests: XCTestCase {
    
    func test_lens_over() {
        let expectedResult = Book.galacticGuideForHitchhikers
            |> lens(\Book.author.name) *~ "ADAMS"
            |> lens(\Book.author.surname) *~ "DOUGLAS"
            |> lens(\Book.title) *~ "galactic guide for hitchhikers ♥️"
        
        let update =
            lens(\Book.author.name).over { $0.uppercased() }
                >>> lens(\Book.author.surname).over { $0.uppercased() }
                >>> lens(\Book.title) %~ { $0 +  " ♥️" }
        
        let newBook = Book.galacticGuideForHitchhikers |> update
        
        XCTAssertEqual(newBook, expectedResult)
    }
    
    func test_F1_map() {
        let f1 = F1(value: 42)
        
        let result = f1 |> map { $0 + 1 }
        
        let doubleIncr = { $0 + 1 } >>> { $0 + 1 }
        let operations = { $0 + 1 } >>> { $0 * $0 }
        
        XCTAssertEqual(result.value, 43)
        XCTAssertEqual(f1 |> map(doubleIncr), F1(value: 44))
        XCTAssertEqual(f1 |> map(doubleIncr >>> String.init), F1(value: "44"))
        XCTAssertEqual(f1 |> map(operations), F1(value: 1849))
    }
    
    func test_F2_map() {
        let f2 = F2<Int, String> { String($0) }
        
        let result = f2.apply(2 |> incr(_:))
        
        let hello = f2 |> map ( { $0 + " hello" } >>> { $0 + "!" } )
        
        XCTAssertEqual(result, "3")
        XCTAssertEqual(hello.apply(1), "1 hello!")
        
        let f21 = F2<String, String> { $0.uppercased() }
        XCTAssertEqual(f21.apply("hello"), "HELLO")
        
        let functorHello = F2<String, String>(apply: { "hello \($0)" })
        
        let resultBob = "bob" |> (functorHello |> map ({ $0.uppercased() } >>> { "\($0)!" } >>> { "\($0) 🤪" })).apply
        
        XCTAssertEqual(resultBob, "HELLO BOB! 🤪")
        
        let _ = [0, 1, 2, 3].map { $0 |> hello.apply } //  f2.apply($0 |> incr(_:))
    }
    
    func test_F2_contramap() {
        let f2 = F2<Int, String> { String($0) }
        
        let reverseMap: (String) -> Int = { s in s.count }
        
        let resultComap = f2 |> contramap(reverseMap)
        
        let resultMap = 4 |> f2.apply
        
        XCTAssertEqual(resultMap, "4")
        XCTAssertEqual(resultComap.apply("ciao"), "4")
    }
    
    func test_F3_map() {
        let save = Parallel<String> { $0("access_token") }
        
        _ = save.run { v in
            print(v)
            // TODO"- save access token here
        }
        
        let t = Parallel<Int> { i in print(i) }
        
        save |> map { v in print(v) }
        
        t.run { $0 + 1 }
        
        let new = save |> map { v in print(v.uppercased())  }
        
        new.run {
            print("")
        }
    }
    
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F1<A>) -> F1<B> {
    return { f1 in
        return f1.value |> f |> F1.init(value:)
    }
}

func map<A, B, C>(_ f: @escaping (B) -> C) -> (F2<A, B>) -> F2<A, C> {
    return { f2 in
        F2(apply: f2.apply >>> f)
    }
    //    return { f2 in
    //        F2 { a in
    //            return f(f2.apply(a))
    //        }
    //    }
}

func contramap<A, B, C>(_ f: @escaping (B) -> A) -> ((F2<A, C>) -> F2<B, C>) {
    return { g in
        //F2(apply: f >>> g.apply)
        F2(apply: g.apply <<< f)
    }
}
