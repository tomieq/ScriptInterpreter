//
//  Instance.swift
//
//
//  Created by Tomasz Kucharski on 23/03/2022.
//

import Foundation

enum Instance {
    case primitive(Value)
    case `class`(type: String, state: VariableRegistry)

    var type: String {
        switch self {
        case .primitive(let value):
            return value.type
        case .class(let type, _):
            return "class.\(type)"
        }
    }

    var asString: String {
        switch self {
        case .primitive(let value):
            return value.asString
        case .class(let type, _):
            return "class.\(type)"
        }
    }
}
