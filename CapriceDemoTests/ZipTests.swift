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
        _ = Array(zip(ys.indices, ys)) // [(3, 7), (4, 11)]
        _ = Array(ys.enumerated())     // [(0, 7), (1, 11)]
        
        _ = Array(zip(xs.dropFirst(1), xs))
        
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
    
    func test_zip_with() {
        let _ = zip([1, 2, 3], ["one", "two", "three"])
        
        let _ = zip([1, 2, 3], ["one", "two", "three"], [true, false, true])
        
        //XCTAssertEqual(result, [(1, "one"), (2, "two"), (3, "three")])
        
        let _ = zip(with: +)([1, 2, 3], [4, 5, 6])
    }
    
    func test_zip_optional() {
        let a: Int? = 1
        let b: Int? = 2
        
        _ = zip(a, b)
        
        let result = (a, b) |> zip(with: +)
        
        if let a = a, let b = b {
            let expectedResult = a + b
            
            XCTAssertEqual(result, expectedResult)
        }
        
        let c: Int? = nil
        let d: String? = " ciao"
        
        let t = zip(c, d)
        dump(t?.0)
    }
    
    func test_zip_validated() {
        let r = compute(2, 3)
        
        XCTAssertEqual(r, 3.1462643699419726)
        
        let validatedResult = zip(with: compute)(
            validate(2, label: "first"),
            validate(3, label: "second")
        )
        
        guard case let Validated.valid(value) = validatedResult else {
            fatalError()
        }
        
        XCTAssertEqual(value, 3.1462643699419726)
    }
    
    func test_zip_validated_failure() {
        let validatedResult = zip(with: compute)(
            validate(-2, label: "first"),
            validate(3, label: "second")
        )
        
        guard case let Validated.invalid(value) = validatedResult else {
            fatalError()
        }
        
        XCTAssertEqual(value.first, "first must be non-negative")
        
        XCTAssertEqual(compute(1, 2, 3, 4, 5), 8.382332347441762)
    }
    
    // MARK: - Task
    
    func test_map_task() {
        let uppercased = Func<String, String> { $0.uppercased() }
        let f: (String) -> Int = { $0.count }
        
        let func2 = uppercased |> map(f)
        let _ = func2.apply("hello")
        
        XCTAssertEqual((uppercased |> map(f)).apply("hello"), 5)
        
        //let five = zip(with: +)(Func { 2 }, Func { 3 }).apply(())
        //XCTAssertEqual(five, 5)
        
        //        let first = Func<String, Int> { $0.count }
        //        let second = Func<String, Int> { $0.count }
        //
        //        let z = zip(first, second)
        //
        //        let result = zip(with: +)(first, second)
        //
        //        let i = result?.apply
        //        dump(i)
        
        //zip(with: { $0 + $1 })(first, second)
        
        //zip(with: { (a: String, b: String) in a + b })(Func { _ in "Hello" }, Func { _ in " world!" })
                
    }
    
    func test_aaaa() {
        let randomNumber = Func<Void, Int> {
            (try? String(contentsOf: URL(string: "https://www.random.org/integers/?num=1&min=1&max=30&col=1&base=10&format=plain&rnd=new")!))
                .map { $0.trimmingCharacters(in: .newlines) }
                .flatMap(Int.init)
                ?? 0
        }
        
        let result = randomNumber.apply(())
        
        XCTAssertTrue(result > 0)
        
        let expectation = XCTestExpectation(description: "")
        
        //wait(for: [expectation], timeout: TimeInterval(30))
        
        let aWordFromPointFree = Func<Void, String> {
            (try? String(contentsOf: URL(string: "https://www.pointfree.co")!))
                .map { $0.split(separator: " ")[1566] }
                .map(String.init)
                ?? "PointFree"
        }
        
        let word = aWordFromPointFree.apply(())
//        XCTAssertEqual(word, "d-pt4")
        
        //zip(with: [String].init(repeating:count:))(aWordFromPointFree, randomNumber)
    }
    
    func test_zip_f3() {
        let anInt = Parallel<Int> { callback in
          delay(by: 0.5) {
            callback(42)
          }
        }

        let aMessage = Parallel<String> { callback in
          delay(by: 1) {
            callback("Hello!")
          }
        }

//        zip(with: Array.init(repeating:count:))(
//          aMessage,
//          anInt
//          )
//          .run { value in
//            print(value)
//        }
        
        //        zip(with: Array.init(repeating:count:))(
        //          aMessage,
        //          anInt
        //          )
        //          .run { value in
        //            print(value)
        //        }
        
    }
}

func delay(by duration: TimeInterval, line: UInt = #line, execute: @escaping () -> Void) {
    print("delaying line \(line) by \(duration)")
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        execute()
        print("executed line \(line)")
    }
}

// flatMap?
//func zip<A, B>(_ fa: F3<A>, _ fb: F3<B>) -> F3<(A, B)> {
//    return F3 { callback in
//        fa.run { a in
//            fb.run { b in
//                callback((a, b))
//            }
//        }
//    }
//}
