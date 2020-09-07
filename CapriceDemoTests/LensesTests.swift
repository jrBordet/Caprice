//
//  LensesTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 04/08/2020.
//

import XCTest
@testable import Caprice


// A functor is a type that carries with it a map-like function.
// So, we think it’s helpful to eschew any overly intuitive description of functor and instead rely only on it’s most basic property: the fact that it has a map function, and that the map function must satisfy the property that map(id) == id. And then from that we get to derive the wonderful property that map preserves function composition, i.e. map(f >>> g) == map(f) >>> map(g).


struct F1<A: Equatable>: Equatable {
    static func == (lhs: F1<A>, rhs: F1<A>) -> Bool {
        lhs.value == rhs.value
    }
    
    let value: A
}

struct F2<A, B> {
    let apply: (A) -> B
}

// //URLSession.shared.dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>) -> Void
struct F3<A> {
    let run: (@escaping (A) -> Void) -> Void
}

class LensesTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_example() throws {
        let surname = books
            .filter(by(^\.author.name, "Massimo"))
            .map(^\.author)
            .map(^\.surname)
            .reduce("", +)
            .lowercased()
        
        XCTAssertEqual(surname, "pigliucci")
    }
    
    func test_lens_set() {
        let result = user |> \.email *~ "another@mail.com"
        
        let newUser = lens(\User.id).set(0, user)
        XCTAssertEqual(newUser |> ^\User.id, 0)
        
        let id = lens(\User.id).get(user)
        
        XCTAssertEqual(id, 1)
        XCTAssertEqual(result.email, "another@mail.com")
    }
    
    func test_lens_set_composition() {
        let book: Book = .stoicism
            |> lens(\Book.author)
            >>> lens(\Author.name)
            *~ "new author name"
        
        XCTAssertEqual(book |> ^\Book.author.name, "new author name")
    }
    
    func test_lens_get_composition() {
        let name = .stoicism |> (lens(\Book.author) >>> lens(\Author.name)).get
        
        XCTAssertEqual(name, "Massimo")
    }
    
    func test_lens_set_nested_keypath() {
        let result: Book = .it |> \Book.author.name *~ "new author"
        
        XCTAssertEqual(result |> ^\Book.author.name, "new author")
        
        let name = .galacticGuideForHitchhikers |> ^\Book.author.name
        let newBook = .galacticGuideForHitchhikers |> \Book.author.name *~ "Adams Noël"
        
        XCTAssertEqual(name, "Adams")
        XCTAssertEqual(newBook.author.name, "Adams Noël")
    }
    
    func test_map_result() {
        let result = Result<Int, NSError>.success(42).map(incr(_:))
        
        guard case .success(let value) = result else {
            fatalError()
        }
        
        XCTAssertEqual(value, 43)
    }
    
    // MARK: - Single Type Composition
    
    func test_single_type() {
        var u = User.empty
        
        let email: (inout User) -> Void = { value in
            value.email = "update@gmail.com"
        }
        
        let email2: (inout User) -> Void = { value in
            value.email = "update2@gmail.com"
        }
        
        let id: (inout User) -> Void = { value in
            value.id = 1
        }
        
        let composition: Void = (email <> id <> email2)(&u)
        
        composition
        
        XCTAssertEqual(u.email, "update2@gmail.com")
        XCTAssertEqual(u.id, 1)
    }
    
    // MARK: - Functors
    
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
        
        let r = [0, 1, 2, 3].map { $0 |> hello.apply } //  f2.apply($0 |> incr(_:))
        print(r)
    }
    
    func test_F3_map() {
        let save = F3<String> { $0("access_token") }
        
        _ = save.run { v in
            print(v)
            // TODO"- save access token here
        }
        
        let t = F3<Int> { i in print(i) }
        
        save |> map { v in print(v) }
        
        t.run { $0 + 1 }
        
        let new = save |> map { v in print(v.uppercased())  }
        
        new.run {
            print("")
        }
    }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
    return { f3 in
        F3 { callback in
            //            f3.run // ((A) -> Void) -> Void
            //            callback // (B) -> Void
            //            f // (A) -> B
            let _ = f >>> callback // (A) -> Void
            
            return f3.run(f >>> callback)
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
