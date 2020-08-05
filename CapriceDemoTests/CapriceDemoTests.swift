//
//  AppThemeTests.swift
//  AppThemeTests
//
//  Created by Jean Raphael Bordet on 22/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import XCTest
@testable import Caprice

class AppThemeTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_forrward_application() {
        XCTAssertEqual(1 |> incr, 2)
    }
    
    func test_functional_getter() {
        let userIdLens = get(\User.id)
        
        XCTAssertEqual(userIdLens(user), 1)
        
        XCTAssertEqual(user |> get(\User.id) >>> String.init, "1")
        
        let isStaff = user |> get(\User.isStaff)
        
        XCTAssertTrue(isStaff)
                
        let emails2 = users.map(get(\.email))
        
        XCTAssertEqual(emails2, ["blob@fake.co", "protocol.me.maybe@appleco.example", "bee@co.domain", "a.morphism@category.theory"])
        
        XCTAssertTrue(users.filter(get(\.isStaff)).isEmpty)
    }
    
    func test_get() {
        let id = user |> ^\.id
        
        XCTAssertEqual(id, 1)
    }
    
    func test_map_composition() {
        _ = users
            .map(\.email)
            .map(^\.count)
        
        // it’s a nice performance gain, too! A single traversal instead of two.
        let r = users.map(^\User.email >>> ^\.count)
        
        let p = users.map(^\.id).reduce(0, +)
                
        XCTAssertEqual(p, 10)
        
        _ = users
            .map(get(\.email.count))
        
        _ = users
            .filter(get(\.isStaff) >>> (!))
    }
    
    func test_filter_composition() {
        self.measure {
            let result = users
                .filter(get(\.isStaff) >>> { $0 == true })
            
            XCTAssertEqual(result.count, 0)
        }
    }
    
    func test_filter() {
        let userOne = users.filter { $0 |> ^\User.id == 1 }.first!
                
        XCTAssertEqual(userOne, User(id: 1, email: "blob@fake.co"))
        
        let authors = books.filter(by(^\.author.name, "Massimo"))
        
        let surname = books
            .filter(by(^\.author.name, "Massimo"))
            .map(^\.author)
            .map(^\.surname)
            .reduce("", +)
            .lowercased()
        
        XCTAssertEqual(authors.first?.author, .max)
        XCTAssertEqual(surname, "pigliucci")
    }
    
    func test_filter_composition_2() {
        let r = users.filter(by(^\.id, 1)).first!
                
        XCTAssertEqual(r, User(id: 1, email: "blob@fake.co"))
    }
    
    func test_sorting() {
        let emailResult = users.sorted(by: their(^\.email, <))
        
        XCTAssertEqual(emailResult.first, User(id: 4, email: "a.morphism@category.theory"))
        
        let idResult = users.sorted(by: their(^\User.id, <))
        
        XCTAssertEqual(idResult.first, users.first)
        
        _ = users
            .max(by: their(^\.email))
        
        _ = users
            .min(by: their(^\.email))
    }
    
    func test_reduce() {
        let result = episodes.reduce(0) { $0 + $1.viewCount }
        
        XCTAssertEqual(result, 3620)
        
        let result2 = episodes.reduce(0, combining(^\.viewCount, by: +))
        
        XCTAssertEqual(result2, 3620)
        
        let titleResult = episodes.reduce("", combining(^\.title, by: +))
        
        dump(titleResult)
                
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
