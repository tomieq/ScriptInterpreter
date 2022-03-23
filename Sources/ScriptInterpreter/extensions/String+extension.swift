//
//  String+extension.swift
//
//
//  Created by Tomasz on 23/03/2022.
//

import Foundation

extension String {
    func trimming(_ characters: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: characters))
    }
}
