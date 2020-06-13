//
//  PrecedenceGroups.swift
//  Caprice
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
    // lowerThan: ForwardComposition
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: EffectfulComposition
}

precedencegroup SingleTypeComposition {
    associativity: right
    higherThan: ForwardApplication
}
