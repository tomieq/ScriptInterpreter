//
//  Value.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

public enum Value {
    case string(String)
    case integer(Int)
    case float(Float)
    case bool(Bool)
    
    var type: String {
        switch self {
        case .string(_):
            return "String"
        case .integer(_):
            return "Int"
        case .float(_):
            return "Float"
        case .bool(_):
            return "Bool"
        }
    }
}

extension Value: Equatable {}
extension Value: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let value):
            return value
        case .integer(let value):
            return "\(value)"
        case .float(let value):
            return "\(value)"
        case .bool(let value):
            return "\(value)"
        }
    }
}
