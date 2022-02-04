//
//  Array+extension.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation


extension Array {
    
    subscript(safeIndex index: Int) -> Element? {
        get {
            guard index >= 0 && index < self.count else { return nil }
            return self[index]
        }
        
        set(newValue) {
            guard let value = newValue, index >= 0 && index < self.count else { return }
            self[index] = value
        }
    }
    
    
}

extension Array where Element == Token {
    func split(by splitter: Token) -> [[Token]] {
        var splitted: [[Token]] = []
        var current: [Token] = []
        for token in self {
            if token == splitter {
                splitted.append(current)
                current = []
            } else {
                current.append(token)
            }
        }
        if !current.isEmpty {
            splitted.append(current)
        }
        return splitted
    }
}

extension Array {
    func withAppended(_ elem: Element) -> [Element] {
        var copy = self
        copy.append(elem)
        return copy
    }
    
    func withAppended(_ elems: [Element]) -> [Element] {
        var copy = self
        copy.append(contentsOf: elems)
        return copy
    }
}
