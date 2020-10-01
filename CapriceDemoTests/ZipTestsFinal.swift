//
//  ZipTestsFinal.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 15/09/2020.
//

import XCTest
import Caprice

class ZipTestsFinal: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_zip_init() throws {
        let emails = ["blob@pointfree.co", "blob.jr@pointfree.co", "blob.sr@pointfree.co"]
        let ids = [1, 2, 3]
        let names = ["Blob", "Blob Junior", "Blob Senior"]
        
        let users = zip3(with: User.init)(
            ids,
            emails,
            names
        )
                
        XCTAssertEqual(users.count, 3)
    }
    
    func test_zip_init_safety() {
        let emails = ["blob@pointfree.co", "blob.jr@pointfree.co", "blob.sr@pointfree.co"]
        let ids = [1, 2]
        let names = ["Blob", "Blob Junior", "Blob Senior"]
        
        let users = zip3(with: User.init)(
            ids,
            emails,
            names
        )
        
        XCTAssertEqual(users.count, 2)
    }
    
    func test_zip_on_optional() {
        let optionalEmail: String? = "blob@pointfree.co"
        let optionalId: Int? = 42
        let optionalName: String? = "Blob"
        
        let optionalUser = zip3(with: User.init)(
            optionalId,
            optionalEmail,
            optionalName
        )
        
        XCTAssertNotNil(optionalUser)
    }
    
    func test_zip_validated() {
        let result = zip3(with: User.init)(
            validate(id: 1),
            validate(email: "blob@pointfree.co"),
            validate(name: "Blob")
        )
        
        
        guard case let Validated.valid(value) = result else {
            fatalError()
        }
        
        XCTAssertEqual(value.name, "Blob")
    }
    
    func test_zip_validated_func() {
        let idProvider = Func<Void, Int> { 42 }
        let emailProvider = Func<Void, String> { "blob@pointfree.co" }
        let nameProvider = Func<Void, String> { "Blob" }
        
        let f = zip3(with: User.init)(
            idProvider,
            emailProvider,
            nameProvider
        )
        
        f // Func<Void, User>
        let user = f.apply(())
        XCTAssertEqual(user.id, 42)
    }
    
    func test_zip_validated_func_side_effects() {
        let idProvider = Func<Void, Int> { 42 }
        let emailProvider = Func<Void, String> { "blob@pointfree.co" }
        
        let nameProvider = Func<Void, String> {
            (try? String(contentsOf: URL(string: "https://www.pointfree.co")!))
                .map { $0.split(separator: " ")[1566] }
                .map(String.init)
                ?? "PointFree"
        }
        
        let user = zip3(with: User.init)(
            idProvider,
            emailProvider,
            nameProvider
        ).apply(())
        
        XCTAssertEqual(user |> ^\User.id, 42)
        XCTAssertEqual(user |> ^\User.name, "d-pt4")
    }
    
    func test_zip_side_effects_delayed() {
        let expectation = XCTestExpectation(description: "Download apple.com home page")
        
        let delayedEmail = Parallel<String> { callback in
            delay(by: 0.2) { callback("blob@pointfree.co") }
        }
        let delayedId = Parallel<Int> { callback in
            delay(by: 0.5) { callback(42) }
        }
        let delayedName = Parallel<String> { callback in
            delay(by: 1) { callback("Blob") }
        }
        
        zip3(with: User.init)(
            delayedId,
            delayedEmail,
            delayedName
        ).run { user in
            print(user)
            XCTAssertEqual(user |> ^\User.id, 42)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Applicative
    
    func test_applicative_functor_parallel() {
        let lhs: Parallel<(String) -> Int> = Parallel { callback in
            //            callback  (@escaping (String) -> Int) -> Void
        }
        
        //        apply({ (a: String) -> Int in
        //            a.count
        //        }, rhs: Parallel<String> { a in
        //
        //        })
    }
    
    // MARK: - Functors
    
    // Functors are containers you can call map on.
    
    func test_box_map() {
        let box = Box<Int>(1)
        
        let result = box |> map { $0 + 1 } >>> map { $0 }
        
        XCTAssertEqual(result.value, 2)
    }
    
    
}

// MARK: - Functors

public struct Box<A> {
    var value: A
    
    public init(_ value: A) {
        self.value = value
    }
}

func map<A, B>(_ f: @escaping(A) -> B) -> (Box<A>) -> Box<B> {
    return {
        Box($0.value |> f)
    }
}

func apply<A, B, E>(_ lhs: Validated<((A) -> B), E>, rhs: Validated<A, E>) -> Validated<B, [E]> {
    switch lhs {
    case let .valid(value):
        //return map(value($0))
//        let b = map { (a: A) -> B in
//            value(a)
//        }
        
        // func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
        //let z = value |> map(_:) //value |> mapValidated(_:)
       // map(<#T##f: (A) -> B##(A) -> B#>)
        
        break
//        map { a -> B in
//            value(a)
//        }
        
        
    case let .invalid(error):
        return Validated.invalid([error])
    }
    //    switch lhs {
    //    case let .success(value):
    //        return rhs.map { value($0) } // Result<B, E>
    //    case let .failure(error):
    //        return .failure(error)
    //    }
    
    fatalError()
}

// MARK: - Apply for Validated

//extension Validated {
//    func apply<A, B, E>(_ lhs: Validated<((A) -> B), E>, rhs: Validated<A, E>) -> Validated<B, [E]> {
//        switch lhs {
//        case let .valid(value):
//            //return map(value($0))
//
//            let z = value |> rhs.map //value |> mapValidated(_:)
//
//            break
//    //         map { a -> B in
//    //            value(a)
//    //        }
//
//
//        case let .invalid(error):
//            return Validated.invalid([error])
//        }
//    //    switch lhs {
//    //    case let .success(value):
//    //        return rhs.map { value($0) } // Result<B, E>
//    //    case let .failure(error):
//    //        return .failure(error)
//    //    }
//
//        fatalError()
//    }
//}

// public func <*> <T, U>(f: (T -> U)?, x: T?) -> U?

// MARK: - Apply for result

// MARK: - Apply for parallel

// func apply<U>(_ f: Box<((T) -> U)>) -> Box<U> {
// apply: (F<(A) -> B>, F<A>) -> F<B>
// func apply<U>(f: (T -> U)?) -> U? {
// func apply<U>(fs: [Element -> U]) -> [U] {

//func apply<A, B>(_ f: Parallel<((A) -> B)>) -> Parallel<B> {
//    let r = f.run
//    r { a in
//        let b = a(<#A#>)
//
//    }
//    fatalError()
//}

/**
 
 We can define an apply function for every type supporting Applicative,
 which knows how to apply a function wrapped in the context of the type to a value wrapped in the same context
 
 */


func apply<A, B>(_ f: (A) -> B, a: A) -> B {
    f(a)
}

//func apply<A, B>(_ lhs: Result<(A) -> B>, rhs: Result<A>) -> Result<B> {
//    fatalError()
//}

//func apply<A, B>(_ lhs: Parallel<(A) -> B>, rhs: Parallel<A>) -> Parallel<B> {
//
//}
//

func apply<A, B>(_ lhs: Parallel<(A) -> B>, rhs: Parallel<A>) -> Parallel<B> {
    Parallel<B> { callback in
        
        //callback (B) -> Void
        //lhs.run <<< callback
        //lhs.run (@escaping (@escaping (A) -> B) -> Void) -> Void
        
    }
}

//extension Parallel {
//    func pure<A>(_ value: A) -> Parallel<A> {
//        Parallel<A> { callback in
//            callback(value)
//        }
//    }
//
//    func apply<A, B>(_ lhs: Parallel<(A) -> B>, rhs: Parallel<A>) -> Parallel<B> {
//        lhs.run { callback in
//            self.run { a in
//                let parallelA = self.pure(a) // Parallel<A>
//            }
//        }
//
//        let b = map { (a: A) -> B in
//            fatalError()
//        }
//
//        Parallel<B> { callback in
//            var b: B
//            lhs.run { c in
//                //c (A) -> B
//                self.run { a in
//                    // let b = c(a)
//
//                    fatalError()
//                    //callback (B) -> Void
//                    // self.pure(a) // Parallel<A>
//                }
//            }
//
//            //callback(b)
//        }
//
//        fatalError()
//    }
//}

//func apply<A, B>(_ lhs: Parallel<(A) -> B>, rhs: Parallel<A>) -> Parallel<B> {
//    let r = lhs.run // (@escaping (@escaping (A) -> B) -> Void) -> Void
//    //r((@escaping (A) -> B) -> Void)
//    //rhs.run((A) -> Void)
//
//    lhs.run { callback in
//        callback(<#A#>)
//    }
//
//    Parallel<B> { (<#@escaping (B) -> Void#>) in
//
//    }
//    fatalError()
//}

// MARK: - Zip Parallel

// MARK: - Zip Func

// MARK - Zip on Validated

func validate(email: String) -> Validated<String, String> {
    return email.index(of: "@") == nil
        ? .invalid(["email is invalid"])
        : .valid(email)
}

func validate(id: Int) -> Validated<Int, String> {
    return id <= 0
        ? .invalid(["id must be positive"])
        : .valid(id)
}

func validate(name: String) -> Validated<String, String> {
    return name.isEmpty
        ? .invalid(["name can't be blank"])
        : .valid(name)
}
