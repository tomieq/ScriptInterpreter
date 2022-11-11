//
//  RegisterSet.swift
//
//
//  Created by Tomasz KUCHARSKI on 10/11/2022.
//

import Foundation

class RegisterSet {
    let variableRegistry: VariableRegistry
    let localFunctionRegistry: LocalFunctionRegistry
    let externalFunctionRegistry: ExternalFunctionRegistry
    let objectTypeRegistry: ObjectTypeRegistry

    init(variableRegistry: VariableRegistry,
         localFunctionRegistry: LocalFunctionRegistry,
         externalFunctionRegistry: ExternalFunctionRegistry,
         objectTypeRegistry: ObjectTypeRegistry) {
        self.variableRegistry = variableRegistry
        self.localFunctionRegistry = localFunctionRegistry
        self.externalFunctionRegistry = externalFunctionRegistry
        self.objectTypeRegistry = objectTypeRegistry
    }

    func copy(variableRegistry: VariableRegistry? = nil) -> RegisterSet {
        RegisterSet(variableRegistry: variableRegistry ?? self.variableRegistry,
                    localFunctionRegistry: self.localFunctionRegistry,
                    externalFunctionRegistry: self.externalFunctionRegistry,
                    objectTypeRegistry: self.objectTypeRegistry)
    }
}
