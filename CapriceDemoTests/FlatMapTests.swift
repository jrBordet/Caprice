//
//  FlatMapTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import XCTest
import Caprice

// Monads are containers you can call flatMap on.

//    This one is ridiculously easy. flatMap is a function that transforms a value, then re-wrap it in the original container type. It's like map, but you have to provide the container inside your transformation function. I'll show you the implementation:

class FlatMapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
