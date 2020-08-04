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
        
        let emails1 = users.map(\User.email)
        
        let emails2 = users.map(get(\.email))
        
        XCTAssertEqual(emails1, emails2)
        
        XCTAssertTrue(users.filter(get(\.isStaff)).isEmpty)
    }
    
    func test_map_composition() {
        _ = users
            .map(\.email)
            .map(^\.count)
        
        // it’s a nice performance gain, too! A single traversal instead of two.
        _ = users
            .map(get(\.email) >>> get(\.count))
        
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
    
    func test_filter_composition_2() {
        self.measure {
            
            let result = users
                .filter(get(\.isStaff) >>> { $0 == true })
            //                .filter(^\User.isStaff)
            //                .filter { $0.isStaff == false }
            
            XCTAssertEqual(result.count, 0)
        }
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
