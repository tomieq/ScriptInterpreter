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
