//
//  Optional+extension.swift
//
//
//  Created by Tomasz on 09/11/2022.
//

import Foundation

extension Optional {
    var isNil: Bool {
        switch self {
        case .none:
            return true
        case .some:
            return false
        }
    }

    var notNil: Bool {
        !self.isNil
    }
}

extension Optional where Wrapped == String {
    var readable: String {
        switch self {
        case .some(let value):
            return value
        case .none:
            return "nil"
        }
    }
}

extension Optional where Wrapped == Value {
    var readable: String {
        switch self {
        case .some(let value):
            return value.asTypeValue
        case .none:
            return "nil"
        }
    }
}
