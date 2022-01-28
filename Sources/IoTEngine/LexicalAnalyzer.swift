//
//  LexicalAnalyzer.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation

class LexicalAnalyzer {
    let lexer: Lexer
    
    init(lexer: Lexer) {
        self.lexer = lexer
    }
    
    func getTokensBetweenBrackets(indexOfOpeningBracket index: Int) -> [Token] {
        guard let openBracket = self.lexer.tokens[safeIndex: index] else {
            return []
        }
        
        guard case .bracketOpen = openBracket else {
            return []
        }
        var tokens: [Token] = []
        var nextIndex = index + 1
        while let nextToken = self.lexer.tokens[safeIndex: nextIndex]{
            if nextToken == .bracketClose {
                break
            }
            if nextToken != .comma {
                tokens.append(nextToken)
            }
            nextIndex += 1
        }
        return tokens
    }
}
