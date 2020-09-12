//
//  LensesTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 04/08/2020.
//

import XCTest
@testable import Caprice


class LensesTests: XCTestCase {
    // MARK: - Lenses
    
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
}



