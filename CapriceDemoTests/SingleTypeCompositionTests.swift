//
//  SingleTypeCompositionTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 09/09/2020.
//

import XCTest
@testable import Caprice

class SingleTypeCompositionTests: XCTestCase {

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

}
