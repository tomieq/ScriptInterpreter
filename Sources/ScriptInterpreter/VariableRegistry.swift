//
//  VariableRegistry.swift
//
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

enum VariableRegistryError: Error {
    case registerTheSameVariable(name: String)
    case valueDoesNotExist(name: String)
    case typeMismatch(variableName: String, existingType: String, newType: String)
    case cannotModifyConstant(variableName: String)
}

extension VariableRegistryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .registerTheSameVariable(let name):
            return NSLocalizedString("ValueRegistryError.registerTheSameVariable: variable \(name) was already registered", comment: "ValueRegistryError")
        case .valueDoesNotExist(let name):
            return NSLocalizedString("ValueRegistryError.valueDoesNotExist: variable \(name) was not defined", comment: "ValueRegistryError")
        case .typeMismatch(let variableName, let existingType, let newType):
            return NSLocalizedString("ValueRegistryError.typeMismatch: variable \(variableName) is \(existingType) but \(newType) is trying to be set", comment: "ValueRegistryError")
        case .cannotModifyConstant(let variableName):
            return NSLocalizedString("ValueRegistryError.cannotModifyConstant: variable \(variableName) is a constant so it cannot be modified", comment: "ValueRegistryError")
        }
    }
}

fileprivate struct VariableContainer {
    var variable: Instance?

    init(_ variable: Instance?) {
        self.variable = variable
    }
}

class VariableRegistryID {
    private static var counter = 0
    static var next: String {
        defer {
            Self.counter += 1
        }
        return String(format: "%03d", Self.counter)
    }
}

class VariableRegistry {
    let id: String
    private let logTag = "🦆 VariableRegistry"
    private let topVariableRegistry: VariableRegistry?
    private var variables: [String: VariableContainer] = [:]
    private var constantNames: [String] = []

    init(topVariableRegistry: VariableRegistry? = nil, idPrefix: String? = nil) {
        self.id = idPrefix.isNil ? VariableRegistryID.next : "\(idPrefix.readable).\(VariableRegistryID.next)"
        self.topVariableRegistry = topVariableRegistry
        let parentID = topVariableRegistry?.id
        let parentInfo = parentID.isNil ? "" : " to parentID: \(parentID!)"
        Logger.v(self.logTag, "Created new registry: \(self.id)" + parentInfo)
    }

    func registerVariable(name: String, variable: Instance?) throws {
        if variable != nil, self.variables[name] != nil {
            throw VariableRegistryError.registerTheSameVariable(name: name)
        }
        self.variables[name] = VariableContainer(variable)
        Logger.v(self.logTag, "new variable \(name) = \(variable?.asTypeValue ?? "nil") in registry: \(self.id)")
    }

    func registerConstant(name: String, variable: Instance?) throws {
        try self.registerVariable(name: name, variable: variable)
        self.constantNames.append(name)
    }

    func updateVariable(name: String, variable: Instance?) throws {
        if let oldVariableContainer = self.variables[name] {
            if self.constantNames.contains(name) {
                Logger.e(self.logTag, "Variable \(name) is a constant. You cannot modify it. RegistryID: \(self.id)")
                throw VariableRegistryError.cannotModifyConstant(variableName: name)
            }
            if let oldVariableType = oldVariableContainer.variable?.type, let newVariableType = variable?.type {
                guard oldVariableType == newVariableType else {
                    throw VariableRegistryError.typeMismatch(variableName: name, existingType: oldVariableType, newType: newVariableType)
                }
            }
            self.variables[name] = VariableContainer(variable)
            Logger.v(self.logTag, "set \(name) = \(variable?.asTypeValue ?? "nil") in registryID: \(self.id)")
            return
        }
        if let upperValueRegistry = self.topVariableRegistry {
            try upperValueRegistry.updateVariable(name: name, variable: variable)
            return
        }
        throw VariableRegistryError.valueDoesNotExist(name: name)
    }

    func getVariable(name: String) -> Instance? {
        return self.variables[name]?.variable ?? self.topVariableRegistry?.getVariable(name: name)
    }

    func variableExists(name: String) -> Bool {
        return self.variables[name] != nil || (self.topVariableRegistry?.variableExists(name: name) ?? false)
    }

    func memoryDump() -> [String: Value] {
        var dump: [String: Value] = self.topVariableRegistry?.memoryDump() ?? [:]
        self.variables.forEach{ (key, variableContainer) in
            switch variableContainer.variable {
            case .none:
                break
            case .some(let instance):
                switch instance {
                case .primitive(let value):
                    dump[key] = value
                case .class(_, _):
                    break
                }
            }
        }
        return dump
    }

    func clearMemory() {
        self.variables = [:]
    }

    func makeCopy(idPrefix: String? = nil) -> VariableRegistry {
        let registry = VariableRegistry(topVariableRegistry: self.topVariableRegistry,
                                        idPrefix: idPrefix ?? "copy:\(self.id)")
        registry.variables = self.variables
        registry.constantNames = self.constantNames
        return registry
    }
}
