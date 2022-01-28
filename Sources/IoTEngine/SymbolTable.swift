//
//  SymbolTable.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

class SymbolTable {
    private var functions: [String:()->()] = [:]
    
    func registerFunc(name: String, function: @escaping ()->()) {
        self.functions[name] = function
    }
    
    func callFunction(name: String) {
        self.functions[name]?()
    }
}
