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

    var asTypeValue: String {
        switch self {
        case .primitive(let value):
            return value.asTypeValue
        case .class(let type, _):
            return "class.\(type)"
        }
    }

    var primitive: Value? {
        switch self {
        case .primitive(let value):
            return value
        case .class(_, _):
            return nil
        }
    }
}
