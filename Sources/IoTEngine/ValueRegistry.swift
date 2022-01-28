//
//  ValueRegistry.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

struct ValueContainer {
    var value: Value?
    
    init(_ value: Value?) {
        self.value = value
    }
}

class ValueRegistry {
    private var values: [String: ValueContainer] = [:]
    
    func registerValue(name: String, value: Value?) {
        self.values[name] = ValueContainer(value)
    }
    
    func setValue(name: String, value: Value?) {
        self.values[name] = ValueContainer(value)
    }
    
    func getValue(name: String) -> Value? {
        return self.values[name]?.value
    }
    
    func valueExists(name: String) -> Bool {
        return self.values[name] != nil
    }
}
