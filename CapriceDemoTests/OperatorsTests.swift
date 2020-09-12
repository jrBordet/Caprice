//
//  OperatorsTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 09/09/2020.
//

import XCTest
@testable import Caprice

class OperatorsTests: XCTestCase {

    func test_map() throws {
        let surname = books
            .filter(by(^\.author.name, "Massimo"))
            .map(^\.author.surname)
            .reduce("", +)
            .lowercased()
        
        XCTAssertEqual(surname, "pigliucci")
    }
    
    func test_query() throws {
        let book = books.filter(by(^\.author.name, "Massimo"))
        
        XCTAssertEqual(book.first?.author.name, "Massimo")
    }
    
    func test_sorting() {
        let usersSorted = users.sorted(by: their(^\User.id, >))
        
        XCTAssertEqual(usersSorted.first!.id, 4)
    }

}
