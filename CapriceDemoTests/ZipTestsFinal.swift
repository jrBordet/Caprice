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
    
    // Monads are containers you can call flatMap on.
    
//    This one is ridiculously easy. flatMap is a function that transforms a value, then re-wrap it in the original container type. It's like map, but you have to provide the container inside your transformation function. I'll show you the implementation:
    
    
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

// MARK: - Apply operator

precedencegroup Apply { associativity: left }
infix operator <*>: Apply

func <*><A, B, E>(_ lhs: Result<((A) -> B), E>, rhs: Result<A, E>) -> Result<B, E> {
    switch lhs {
    case let .success(value):
        return rhs.map { value($0) } // Result<B, E>
    case let .failure(error):
        return .failure(error)
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
        map(<#T##f: (A) -> B##(A) -> B#>)
        
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

func apply<A, B, E>(_ lhs: Result<((A) -> B), E>, rhs: Result<A, E>) -> Result<B, E> {
    switch lhs {
    case let .success(value):
        return rhs.map { value($0) } // Result<B, E>
    case let .failure(error):
        return .failure(error)
    }
}

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

extension Validated {
    func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
        return { validated in
            switch validated {
            case let .valid(a):
                return .valid(f(a))
            case let .invalid(e):
                return .invalid(e)
            }
        }
    }
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
    return { validated in
        switch validated {
        case let .valid(a):
            return .valid(f(a))
        case let .invalid(e):
            return .invalid(e)
        }
    }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (Parallel<A>) -> Parallel<B> {
    return { f3 in
        return Parallel { callback in
            f3.run { callback(f($0)) }
        }
    }
}

func zip2<A, B>(_ fa: Parallel<A>, _ fb: Parallel<B>) -> Parallel<(A, B)> {
    return Parallel<(A, B)> { callback in
        var a: A?
        var b: B?
        fa.run {
            a = $0
            if let b = b { callback(($0, b)) }
        }
        fb.run {
            b = $0
            if let a = a { callback((a, $0)) }
        }
    }
}

func zip2<A, B, C>(
    with f: @escaping (A, B) -> C
) -> (Parallel<A>, Parallel<B>) -> Parallel<C> {
    
    return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C>(_ fa: Parallel<A>, _ fb: Parallel<B>, _ fc: Parallel<C>) -> Parallel<(A, B, C)> {
    return zip2(fa, zip2(fb, fc)) |> map { ($0, $1.0, $1.1) }
}

func zip3<A, B, C, D>(
    with f: @escaping (A, B, C) -> D
) -> (Parallel<A>, Parallel<B>, Parallel<C>) -> Parallel<D> {
    
    return { zip3($0, $1, $2) |> map(f) }
}

// MARK: - Zip Func

func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
    return Func<R, (A, B)> { r in
        (r2a.apply(r), r2b.apply(r))
    }
}

func zip3<A, B, C, R>(
    _ r2a: Func<R, A>,
    _ r2b: Func<R, B>,
    _ r2c: Func<R, C>
) -> Func<R, (A, B, C)> {
    
    return zip2(r2a, zip2(r2b, r2c)) |> map { ($0, $1.0, $1.1) }
}

func zip2<A, B, C, R>(
    with f: @escaping (A, B) -> C
) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {
    
    return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, D, R>(
    with f: @escaping (A, B, C) -> D
) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {
    
    return { zip3($0, $1, $2) |> map(f) }
}

// MARK - Zip on Validated

func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
    switch (a, b) {
    case let (.valid(a), .valid(b)):
        return .valid((a, b))
    case let (.valid, .invalid(e)):
        return .invalid(e)
    case let (.invalid(e), .valid):
        return .invalid(e)
    case let (.invalid(e1), .invalid(e2)):
        return .invalid(e1 + e2)
    }
}

func zip2<A, B, C, E>(
    with f: @escaping (A, B) -> C
) -> (Validated<A, E>, Validated<B, E>) -> Validated<C, E> {
    
    return { zip2($0, $1) |> map(f) }
}

func zip3<A, B, C, E>(_ a: Validated<A, E>, _ b: Validated<B, E>, _ c: Validated<C, E>) -> Validated<(A, B, C), E> {
    return zip2(a, zip2(b, c))
        |> map { a, bc in (a, bc.0, bc.1) }
}

func zip3<A, B, C, D, E>(
    with f: @escaping (A, B, C) -> D
) -> (Validated<A, E>, Validated<B, E>, Validated<C, E>) -> Validated<D, E> {
    
    return { zip3($0, $1, $2) |> map(f) }
}

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

// MARK - Zip on Array

func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    (0..<min(xs.count, ys.count)).forEach { idx in
        result.append((xs[idx], ys[idx]))
    }
    return result
}

func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
    return zip2(xs, zip2(ys, zs)) // [(A, (B, C))]
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
    with f: @escaping (A, B) -> C
) -> ([A], [B]) -> [C] {
    
    return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
    with f: @escaping (A, B, C) -> D
) -> ([A], [B], [C]) -> [D] {
    
    return { zip3($0, $1, $2).map(f) }
}

// MARK: - Zip on optional

func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a = a, let b = b else { return nil }
    return (a, b)
}

func zip3<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
    return zip2(a, zip2(b, c))
        .map { a, bc in (a, bc.0, bc.1) }
}

func zip2<A, B, C>(
    with f: @escaping (A, B) -> C
) -> (A?, B?) -> C? {
    
    return { zip2($0, $1).map(f) }
}

func zip3<A, B, C, D>(
    with f: @escaping (A, B, C) -> D
) -> (A?, B?, C?) -> D? {
    
    return { zip3($0, $1, $2).map(f) }
}
