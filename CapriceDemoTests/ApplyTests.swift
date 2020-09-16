//
//  ApplyTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import XCTest
import Caprice

class ApplyTests: XCTestCase {

    func test_apply_result_success() throws {
        let lhs: Result<((String) -> Int), NSError> = Result.success { $0.count }
        let rhs: Result<String, NSError> = Result.success("hello")
        
        //        let result = apply(lhs, rhs: rhs)
        
        let result = lhs <*> rhs
        
        let v = try result.get()
        
        XCTAssertEqual(v, 5)
    }
    
    func test_apply_result_failure() throws {
        let lhs: Result<((String) -> Int), NSError> = .success { $0.count }
        let rhs: Result<String, NSError> = .failure(NSError(domain: "", code: 3, userInfo: nil))
        
        let result = lhs <*> rhs
        
        guard case let .failure(value) = result else {
            fatalError()
        }
        
        XCTAssertEqual(value.code, 3)
    }

}
