//
//  LensesTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 04/08/2020.
//

import XCTest
@testable import Caprice

class LensesTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
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
        
        //lens(\User.id).set
        
        let id = lens(\User.id).get(user)
        
        XCTAssertEqual(result.email, "another@mail.com")
    }
    
    func test_lens_set_nested_keypath() {
        let result: Book = .it |> \.author.name *~ "new author"
        
        XCTAssertEqual(result |> ^\Book.author.name, "new author")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
