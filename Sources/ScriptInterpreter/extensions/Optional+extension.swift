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
