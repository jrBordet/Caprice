//
//  ZipTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 12/09/2020.
//

import XCTest
import Caprice

class ZipTests: XCTestCase {

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
