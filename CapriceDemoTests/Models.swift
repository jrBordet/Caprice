//
//  Models.swift
//  CapriceDemoTests
//
//  Created by Jean Raphael Bordet on 04/08/2020.
//

import Foundation

func incr(_ x: Int) -> Int {
    x + 1
}

let user = User(id: 1, email: "blob@syn.com")

public struct User: Equatable {
    let id: Int
    let email: String
    
    public init(
        id: Int,
        email: String
    ) {
        self.id = id
        self.email = email
    }
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
