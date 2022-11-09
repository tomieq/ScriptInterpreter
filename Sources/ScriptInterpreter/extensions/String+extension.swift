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

extension String {
    func appendingRandomHexDigits(length: Int) -> String {
        let letters = "ABCDEF0123456789"
        let digits = String((0..<length).map{ _ in letters.randomElement()! })
        return self.appending(digits)
    }
}
