//
//  Value.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum ValueError: Error {
    case variableNotFound(info: String)
}

extension ValueError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .variableNotFound(let info):
            return NSLocalizedString("ValueError.variableNotFound \(info) ", comment: "ValueError")
        }
    }
}

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
    
    public var asString: String {
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

extension Value {
    public var isString: Bool {
        if case .string(_) = self {
            return true
        }
        return false
    }
    public var isBool: Bool {
        if case .bool(_) = self {
            return true
        }
        return false
    }
    public var isInteger: Bool {
        if case .integer(_) = self {
            return true
        }
        return false
    }
    public var isFloat: Bool {
        if case .float(_) = self {
            return true
        }
        return false
    }
}

extension Value: Equatable {}
extension Value: CustomStringConvertible {
    public var description: String {
        self.asString
    }
}

extension Value {
    func interpolated(with variableRegistry: VariableRegistry) throws -> Value {
        guard case .string(let txt) = self else {
            return self
        }
        var interpolated = txt
        for match in self.matches(for: "\\\\\\(([a-zA-Z0-9_]+)\\)", in: txt) {
            let variableName = match.trimmingCharacters(in: CharacterSet(charactersIn: "\\()"))
            guard let txt = variableRegistry.getValue(name: variableName)?.asString else {
                throw ValueError.variableNotFound(info: "Error with String interpolation. Variable \(variableName) not registered")
            }
            interpolated = interpolated.replacingOccurrences(of: "\(match)", with: txt, options: [], range: nil)
        }
        return .string(interpolated)
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

extension Value: Hashable {}
