//
//  User.swift
//  CapriceDemo
//
//  Created by Jean Raphael Bordet on 03/08/2020.
//

import Foundation

public struct User {
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

let user = User(id: 1, email: "blob@gmail.com")

