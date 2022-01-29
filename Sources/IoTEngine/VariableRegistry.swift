//
//  VariableRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum VariableRegistryError: Error {
    case valueDoesNotExist(name: String)
    case typeMismatch(variableName: String, existingType: String, newType: String)
    case cannotModifyConstant(variableName: String)
}

extension VariableRegistryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .valueDoesNotExist(let name):
            return NSLocalizedString("ValueRegistryError.valueDoesNotExist: variable \(name) was not defined", comment: "ValueRegistryError")
        case .typeMismatch(let variableName, let existingType, let newType):
            return NSLocalizedString("ValueRegistryError.typeMismatch: variable \(variableName) is \(existingType) but \(newType) is trying to be set", comment: "ValueRegistryError")
        case .cannotModifyConstant(let variableName):
            return NSLocalizedString("ValueRegistryError.cannotModifyConstant: variable \(variableName) is a constant so it cannot be modified", comment: "ValueRegistryError")
        }
    }
}

fileprivate struct ValueContainer {
    var value: Value?
    
    init(_ value: Value?) {
        self.value = value
    }
}

class VariableRegistry {
    private let topVariableRegistry: VariableRegistry?
    private var values: [String: ValueContainer] = [:]
    private var constantNames: [String] = []
    
    init(topVariableRegistry: VariableRegistry? = nil) {
        self.topVariableRegistry = topVariableRegistry
    }
    
    func registerValue(name: String, value: Value?) {
        self.values[name] = ValueContainer(value)
    }
    
    func registerConstant(name: String, value: Value) {
        self.constantNames.append(name)
        self.registerValue(name: name, value: value)
    }
    
    func updateValue(name: String, value: Value?) throws {
        if let oldValue = self.values[name] {
            if self.constantNames.contains(name) {
                throw VariableRegistryError.cannotModifyConstant(variableName: name)
            }
            if let oldValueType = oldValue.value?.type, let newValueType = value?.type {
                guard oldValueType == newValueType else {
                    throw VariableRegistryError.typeMismatch(variableName: name, existingType: oldValueType, newType: newValueType)
                }
            }
            self.values[name] = ValueContainer(value)
            return
        }
        if let upperValueRegistry = self.topVariableRegistry {
            try upperValueRegistry.updateValue(name: name, value: value)
            return
        }
        throw VariableRegistryError.valueDoesNotExist(name: name)
    }
    
    func getValue(name: String) -> Value? {
        return self.values[name]?.value ?? self.topVariableRegistry?.getValue(name: name)
    }
    
    func valueExists(name: String) -> Bool {
        return self.values[name] != nil || (self.topVariableRegistry?.valueExists(name: name) ?? false)
    }
}
