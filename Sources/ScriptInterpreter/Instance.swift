//
//  Instance.swift
//
//
//  Created by Tomasz Kucharski on 23/03/2022.
//

import Foundation

enum Instance {
    case simple(Value)
    case `class`(type: String, state: VariableRegistry)

    var type: String {
        switch self {
        case .simple(let value):
            return value.type
        case .class(let type, _):
            return "class.\(type)"
        }
    }
}
