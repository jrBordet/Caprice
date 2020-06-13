//
//  Alarm+Lenses.swift
//  CapriceDemo
//
//  Created by Jean Raphael Bordet on 13/06/2020.
//

import Foundation
import Caprice

extension Alarm {
    static let titleLens = Lens<Alarm, String>(
        get: { $0.title },
        set: { (t, a) in Alarm(uuid: a.uuid, title: t, enabled: a.enabled, date: a.date) }
    )
    
    static let enabledLens = Lens<Alarm, Bool>(
        get: { $0.enabled },
        set: { (e, a) in Alarm(uuid: a.uuid, title: a.title, enabled: e, date: a.date) }
    )
    
    static let dateLens = Lens<Alarm, Date>(
        get: { $0.date },
        set: { (d, a) in Alarm(uuid: a.uuid, title: a.title, enabled: a.enabled, date: d) }
    )
}

extension Alarm {
    static let morningStar = Alarm(uuid: UUID(), title: "morning star", enabled: true, date: Date())
    static let noon = Alarm(uuid: UUID(), title: "noon", enabled: true, date: Date())
    static let meeting = Alarm(uuid: UUID(), title: "meeting", enabled: true, date: Date())
}
