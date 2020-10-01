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
    
    func test_compute_flatMap() {
        let randomNumber = Func<Void, Int> {
            (try? String(contentsOf: URL(string: "https://www.random.org/integers/?num=1&min=1&max=30&col=1&base=10&format=plain&rnd=new")!))
                .map { $0.trimmingCharacters(in: .newlines) }
                .flatMap(Int.init)
                ?? 0
        }
        
        let aWordFromPointFree = Func<Void, String> {
            (try? String(contentsOf: URL(string: "https://www.pointfree.co")!))
                .map { $0.split(separator: " ")[1566] }
                .map(String.init)
                ?? "PointFree"
        }
        
        let r = compute(42, 1729)
        
        randomNumber.flatMap { number -> Func<Void, Int> in
            aWordFromPointFree |> map { words in
                words.count - number
                //words[number]
                 //Int(words.dropLast(number).first) ?? 0
            }
        }.apply(())
        
//        randomNumber.flatMap { number in
//            aWordFromPointFree.map { words in
//                words[number]
//            }
//        }.apply(())
    }
    
}
