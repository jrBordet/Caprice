//
//  FunctorsTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 09/09/2020.
//

import XCTest
import Caprice

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
    
    func test_parallel_map() {
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
            print("new run")
        }
        
        let d = delay(by: 0).map { 42 }.map { String.init($0) }
        
        d.run {
            print($0)
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
