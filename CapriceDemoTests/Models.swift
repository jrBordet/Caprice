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

let user = User(id: 1, email: "blob@syn.com")

public struct User: Equatable {
    var id: Int
    var email: String
    
    public init(
        id: Int,
        email: String
    ) {
        self.id = id
        self.email = email
    }
}

extension User {
    static var empty = User(id: 0, email: "")
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
    User(id: 1, email: "blob@fake.co"),
    User(id: 2, email: "protocol.me.maybe@appleco.example"),
    User(id: 3, email: "bee@co.domain"),
    User(id: 4, email: "a.morphism@category.theory")
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
