//
//  Models.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 04/08/2020.
//

import Foundation
import Caprice

func incr(_ x: Int) -> Int {
    x + 1
}

let user = User(id: 1, email: "blob@syn.com", name: "Bob")

public struct User: Equatable {
    var id: Int
    var email: String
    var name: String
    
    public init(
        id: Int,
        email: String,
        name: String
    ) {
        self.id = id
        self.email = email
        self.name = name
    }
}

extension User: Decodable { }

extension User {
    static var empty = User(id: 0, email: "", name: "Bob")
}

let books: [Book] = [
    .it,
    .stoicism
]

public struct Book: Equatable {
    var id: Int
    var title: String
    
    var author: Author
}

extension Book {
    static var stoicism = Book(id: 0, title: "Come essere stoico", author: .max)
    static var it = Book(id: 1, title: "IT", author: .king)
    static var galacticGuideForHitchhikers = Book(id: 2, title: "galactic guide for hitchhikers", author: .adams)
}

public struct Author: Equatable {
    var name: String
    var surname: String
}

extension Author {
    static var king = Author(name: "Stephen", surname: "King")
    static var max = Author(name: "Massimo", surname: "Pigliucci")
    static var adams = Author(name: "Adams", surname: "Douglas")
}

extension User {
    var isStaff: Bool {
        return self.email.hasSuffix("@syn.com")
    }
}

let users = [
    User(id: 1, email: "blob@fake.co", name: "Blob"),
    User(id: 2, email: "protocol.me.maybe@appleco.example", name: "Sample"),
    User(id: 3, email: "bee@co.domain", name: "Bee"),
    User(id: 4, email: "a.morphism@category.theory", name: "A")
]

struct Episode {
    let title: String
    let viewCount: Int
}

let episodes = [
    Episode(title: "Functions", viewCount: 961),
    Episode(title: "Side Effects", viewCount: 841),
    Episode(title: "UIKit Styling with Functions", viewCount: 1089),
    Episode(title: "Algebraic Data Types", viewCount: 729),
]
