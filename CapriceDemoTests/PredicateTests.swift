//
//  PredicateTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 09/09/2020.
//

import XCTest
import Caprice

class PredicateTests: XCTestCase {
    func test_predicate() throws {
        let evens = Predicate { $0 % 2 == 0}
        let odds = evens.contramap { $0 + 1 }
        
        XCTAssertFalse(evens.contains(3))
        
        XCTAssertTrue(odds.contains(3))
        XCTAssertTrue(3 |> evens.contramap { $0 + 1 }.contains)
        
        XCTAssertFalse(odds.contains(4))
        
        let isLessThan10 = Predicate<Int> { $0 < 10 }
        let emailcount = isLessThan10.contramap(^\User.email.count) // let _ = (User) -> Int
        
        let result = emailcount.contains(users.first!)
        XCTAssertFalse(result)
        
        let shortStrings = isLessThan10.contramap(get(\String.count))
        
        XCTAssertTrue(shortStrings.contains("Blob"))
        XCTAssertFalse(shortStrings.contains("Blobby McBlob"))
    }
    
    func test_predicate_email() {
        let user = User(
            id: 0,
            email: "email@gmail.com"
        )
        
        let emailPredicate = Predicate<String> {
            $0 |> NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with:)
        }
        
        let userEmailCmp = emailPredicate.contramap(^\User.email)
        
        XCTAssertTrue(user.email |> emailPredicate.contains)
        XCTAssertTrue(user |> userEmailCmp.contains)
        
        let result = users.filter { $0 |> userEmailCmp.contains }
        XCTAssertEqual(result.count, 4)
    }
}

