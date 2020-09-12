//
//  PredicateTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 09/09/2020.
//

import XCTest
import Caprice

class PredicateTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
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
    
    func test_zip() {
        let xs = [2, 3, 5, 7, 11]
        let r = Array(zip(xs.indices, xs))
        dump(r)
        
        let ys = xs.suffix(3)      // [7, 11]
        Array(zip(ys.indices, ys)) // [(3, 7), (4, 11)]
        Array(ys.enumerated())     // [(0, 7), (1, 11)]
        
        Array(zip(xs.dropFirst(1), xs))
        
        zip(xs.dropFirst(1), xs).forEach { p, q in
            p - q == 2
                ? print("\(p) & \(q) are twin primes!")
                : print("\(p) & \(q) are NOT twin primes :(")
        }
        
        let titles = [
            "Functions",
            "Side Effects",
            "Styling with Functions",
            "Algebraic Data Types"
        ]
        
        let friends = [
            "Omar",
            "Ste",
            "Dani",
            "Vale",
            "Elisa",
            "Finanziere",
            "Alex",
            "Morosa di Alex",
            "jR",
            "Pippolina"
        ]
        
        let grigliata = zip(1..., friends).map { n, v -> String in
            "\(n). \(v)"
        }
        
        print(grigliata)
        
        let titlesEnumeratedResult = titles
            .enumerated()
            .map { n, title in "\(n + 1).) \(title)" }
        
        dump(titlesEnumeratedResult)
        
        let titlesZipResult = zip(1..., titles)
            .map { n, title in "\(n).) \(title)" }
        
        XCTAssertEqual(titlesEnumeratedResult, titlesZipResult)
    }
    
    func test_zip_2() {
        let result = zip([1, 2, 3], ["one", "two", "three"])
        
        let zip3 = zip([1, 2, 3], ["one", "two", "three"], [true, false, true])
        
        //XCTAssertEqual(result, [(1, "one"), (2, "two"), (3, "three")])
        
        let zipWith = zip(with: +)([1, 2, 3], [4, 5, 6])
        dump(zipWith)
        

    }
    
    func test_zip_optional() {
        let a: Int? = 1
        let b: Int? = 2
        
        zip(a, b)
        
        let result = (a, b) |> zip(with: +)
        
        if let a = a, let b = b {
            let expectedResult = a + b
            
            XCTAssertEqual(result, expectedResult)
        }
        
    }
    
}

func zip<A, B, C>(
    with f: @escaping (A, B) -> C
) -> (A?, B?) -> C? {
    { zip($0, $1).map(f) }
}

func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard
        let a = a,
        let b = b else {
            return nil
    }
    
    return (a, b)
}

func zip<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    (0..<min(xs.count, ys.count)).forEach { idx in
        result.append((xs[idx], ys[idx]))
    }
    return result
}

func zip<A, B, C>(
    _ xs: [A], _ ys: [B], _ zs: [C]
) -> [(A, B, C)] {
    return zip(xs, zip(ys, zs)) // [(A, (B, C))]
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip<A, B, C>(
    with f: @escaping (A, B) -> C
) -> ([A], [B]) -> [C] {
    return { zip($0, $1).map(f) }
}

