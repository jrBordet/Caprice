//
//  Alarm.swift
//  CapriceDemo
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation

public struct Alarm {
    public var uuid: UUID
    public var title: String
    public var enabled: Bool
    public var date: Date
    
    public init (
        uuid: UUID,
        title: String,
        enabled: Bool,
        date: Date
    ) {
        self.uuid = uuid
        self.title = title
        self.enabled = enabled
        self.date = date
    }
}
