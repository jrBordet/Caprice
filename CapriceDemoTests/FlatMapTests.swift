//
//  FlatMapTests.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 16/09/2020.
//

import XCTest
import Caprice

struct Invoice: Codable {
    let amountDue: Int
    let amountPaid: Int
    let closed: Bool
    let id: Int
}

struct UserEnvelope {
    let user: User
    let invoices: [Invoice]
}

// Monads are containers you can call flatMap on.

//    This one is ridiculously easy. flatMap is a function that transforms a value, then re-wrap it in the original container type. It's like map, but you have to provide the container inside your transformation function. I'll show you the implementation:

//When we see zip we know that we are combining multiple independent contextual values into a single one: in this case, a user loaded from JSON on disk and an array of invoices loaded from disk. Neither of these values depend on each other.

//When we see map we know we are performing a pure, infallible transformation on the underlying value inside the context.

//And when we see flatMap we know we are performing a failable transformation on that value in the context. This computation is dependent on the computations that came before it, whereas the zip is not.

//Now we’re beginning to see how these three operations are kind of forming a mini functional domain-specific language for transforming data. When we see one of these operations we know what it’s doing because each operation is doing something very specific and does it very well.

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
        
        let p = Result<Int, NSError>.success(42).flatMap { (i: Int) -> Result<String, NSError> in
            .success(String(i))
        } // Result<String, NSError>
        
        let p2 = Result<Int, NSError>.success(42).map { (i: Int) -> Result<String, NSError> in
            .success(String(i))
        } // Result<Result<String, NSError>, NSError>
        
        let a = Result<Int, NSError>.success(42).map { v in
            v + 1
        } // Result<Int, NSError>
        
        let p2Type = type(of: p2)
        print(p2Type)
        
        print("")
    }
    
    func test_parallel_flatMap() {
        let aDelayedInt: Parallel<Int> = delay(by: 3).map { 0 }
        
        let expectation = XCTestExpectation(description: "")
        
        aDelayedInt
            .flatMap { value in delay(by: 1).map { value + 1 } }
            .flatMap { value in delay(by: 1).map { value + 2 } }
            .flatMap { value in delay(by: 1).map { value + 3 } }
            .flatMap { value in delay(by: 1).map { value + 4 } }
            .run { value in
                XCTAssertEqual(value, 10)
                expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_user_flatMap() {
        //        let user: User?
        //        if let path = Bundle.main.path(forResource: "user", ofType: "json"),
        //            let url = Optional(URL(fileURLWithPath: path)),
        //            let data = try? Data(contentsOf: url) {
        //
        //            user = try? JSONDecoder().decode(User.self, from: data)
        //        } else {
        //            user = nil
        //        }
        
        let user: User?
        
        if let path = Bundle.main.path(forResource: "user", ofType: "json"),
            case let url = URL(fileURLWithPath: path),
            let data = try? Data(contentsOf: url) {
            
            user = try? JSONDecoder().decode(User.self, from: data)
        } else {
            user = nil
        }
        
    }
    
    func test_nil_handling_pipelines() {
        let newUser = Bundle
            .main
            .path(forResource: "user", ofType: "json")
            .map { URL(fileURLWithPath: $0) }
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode(User.self, from: $0) }
        
        XCTAssertEqual(newUser?.name, "Blob")
        
        let invoices = Bundle.main.path(forResource: "invoices", ofType: "json")
            .map (URL.init(fileURLWithPath:))
            .flatMap { try? Data.init(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode([Invoice].self, from: $0) }
        
        XCTAssertEqual(invoices?.count, 2)
        
        let result = zip(newUser, invoices).map { user, invoices -> Bool in
            invoices.count == 2
        }
        
        XCTAssertTrue(result ?? false)
        
        //        let userEnvelope = zip(with: UserEnvelope.init)(newUser, invoices)
        
        let userEnvelope = (newUser, invoices) |> zip(with: UserEnvelope.init)
        // UserEnvelope.init  (User, [Invoice]) -> UserEnvelope
        dump(userEnvelope)
        
    }
    
    func test_error_pipeline() {
        //        do {
        //            let user: User?
        //            if let path = Bundle.main.path(forResource: "user", ofType: "json"),
        //                case let url = URL(fileURLWithPath: path) {
        //                let data = try Data(contentsOf: url)
        //
        //                user = try JSONDecoder().decode(User.self, from: data)
        //            } else {
        //                user = nil
        //            }
        //        } catch {
        //
        //        }
        
        //        do {
        //          let path = try requireSome(Bundle.main.path(forResource: "user", ofType: "json"))
        //          let url = URL(fileURLWithPath: path)
        //          let data = try Data(contentsOf: url)
        //          let user = try JSONDecoder().decode(User.self, from: data)
        //        } catch {
        //
        //        }
        
        //        do {
        //            let user = try JSONDecoder().decode(
        //                User.self,
        //                from: Data(
        //                    contentsOf: URL(
        //                        fileURLWithPath: requireSome(
        //                            Bundle.main.path(
        //                                forResource: "user",
        //                                ofType: "json"
        //                            )
        //                        )
        //                    )
        //                )
        //            )
        //        } catch {
        //
        //        }
        
        
        //        let path = Result { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
        //        let url = path.map(URL.init(fileURLWithPath:))
        //        let data = url.flatMap { url in Result { try Data(contentsOf: url) } }
        //        let userResult = data.flatMap { data in Result { try JSONDecoder().decode(User.self, from: data) } }
        
        //        let userResult = Result { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
        //            .map(URL.init(fileURLWithPath:))
        //            .flatMap { url in Result { try Data(contentsOf: url) } }
        //            .flatMap { data in Result { try JSONDecoder().decode(User.self, from: data) }
        
        let userInvoicesResult = zip( // Result<(User, [Invoice]), Error>
            Result { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
                .map(URL.init(fileURLWithPath:))
                .flatMap { url in Result { try Data.init(contentsOf: url) } }
                .flatMap { data in Result { try JSONDecoder().decode(User.self, from: data) } },
            
            Result { try requireSome(Bundle.main.path(forResource: "invoices", ofType: "json")) }
                .map(URL.init(fileURLWithPath:))
                .flatMap { url in Result { try Data.init(contentsOf: url) } }
                .flatMap { data in Result { try JSONDecoder().decode([Invoice].self, from: data) } }
        )
        
        //        zip(with: Result<UserEnvelope, Error>)(
        //            Result { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
        //                .map(URL.init(fileURLWithPath:))
        //                .flatMap { url in Result { try Data.init(contentsOf: url) } }
        //                .flatMap { data in Result { try JSONDecoder().decode(User.self, from: data) } },
        //
        //            Result { try requireSome(Bundle.main.path(forResource: "invoices", ofType: "json")) }
        //                .map(URL.init(fileURLWithPath:))
        //                .flatMap { url in Result { try Data.init(contentsOf: url) } }
        //                .flatMap { data in Result { try JSONDecoder().decode([Invoice].self, from: data) } }
        //        )
        
//        let adhsdfdsf = zip(
//          Validated { try requireSome(Bundle.main.path(forResource: "user", ofType: "json")) }
//            .map(URL.init(fileURLWithPath:))
//            .flatMap { url in Validated { try Data(contentsOf: url) } }
//            .flatMap { data in Validated { try JSONDecoder().decode(User.self, from: data) } },
//
//          Validated { try requireSome(Bundle.main.path(forResource: "invoices", ofType: "json")) }
//            .map(URL.init(fileURLWithPath:))
//            .flatMap { url in Validated { try Data.init(contentsOf: url) } }
//            .flatMap { data in Validated { try JSONDecoder().decode([Invoice].self, from: data) } }
//        )
        
    }
    
    func test_asynchronous_pipelines() {
        let expectation = XCTestExpectation(description: "")

        let a1 = Parallel { callback in callback(Bundle.main.path(forResource: "user", ofType: "json")!) }
            .map(URL.init(fileURLWithPath:))
            .flatMap { url in Parallel { callback in callback(try! Data(contentsOf: url)) } }
            .flatMap { data in Parallel { callback in callback(try! JSONDecoder().decode(User.self, from: data)) } }
        // Parallel<User>
        
        a1.run { r in
            dump(user)
            //expectation.fulfill()
        }
        
        
//        Parallel { Bundle.main.path(forResource: "user", ofType: "json")! }
//            .map(URL.init(fileURLWithPath:))
//            .flatMap { url in Parallel { try! Data(contentsOf: url) } }
//            .flatMap { data in Parallel { try! JSONDecoder().decode(User.self, from: data) } }
        
        let a2 = Parallel(Bundle.main.path(forResource: "user", ofType: "json")!)
            .map(URL.init(fileURLWithPath:))
            .flatMap { url in Parallel(try! Data(contentsOf: url)) }
            .flatMap { data in Parallel(try! JSONDecoder().decode(User.self, from: data)) }
        // Parallel<User>
        
        a2.run { user in
            dump(user)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)

    }
    
    struct SomeExpected: Error {}
    
    func requireSome<A>(_ a: A?) throws -> A {
        guard let a = a else {
            throw SomeExpected()
        }
        
        return a
    }
    
    func test_validation_pipeline() {
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

//extension Parallel {
//    init(_ work: @escaping () -> A) {
//        self = Parallel { callback in
//            DispatchQueue.global().async {
//                callback(work())
//            }
//        }
//    }
//}

extension Parallel {
    init(_ work: @autoclosure @escaping () -> A) {
        self = Parallel { callback in
            DispatchQueue.global().async {
                callback(work())
            }
        }
    }
}

//extension Validated {
//    init<A>(catching f: () throws -> A) {
//        do {
//            let v = try f
//            self = .valid(try f() as! Value)
//        } catch let e {
//            self = .invalid(SomeExpected())
//        }
//    }
//}

//extension Validated where E == Swift.Error {
//    init(catching f: () throws -> A) {
//        do {
//            self = .valid(try f())
//        } catch {
//            self = .invalid([error])
//        }
//    }
//}

//extension Result where E == Swift.Error {
//    init(catching f: () throws -> A) {
//        do {
//            self = .success(try f())
//        } catch {
//            self = .failure(error)
//        }
//    }
//}
