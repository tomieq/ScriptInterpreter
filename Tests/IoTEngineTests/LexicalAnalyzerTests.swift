//
//  LexicalAnalyzerTests.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class LexicalAnalyzerTests: XCTestCase {
    
    func test_getTokensBetweenBrackets() {
        do {
            let code = "someFunction(78, false) secondFunction(12.3, 'monkey')"
            let lexer = try Lexer(code: code)
            let lexicalAnalyzer = LexicalAnalyzer(lexer: lexer)
            var arguments = lexicalAnalyzer.getTokensBetweenBrackets(indexOfOpeningBracket: 1)
            XCTAssertEqual(arguments.count, 2)
            XCTAssertEqual(arguments.first, .intLiteral(78))
            XCTAssertEqual(arguments.last, .boolLiteral(false))

            arguments = lexicalAnalyzer.getTokensBetweenBrackets(indexOfOpeningBracket: 7)
            XCTAssertEqual(arguments.count, 2)
            XCTAssertEqual(arguments.first, .floatLiteral(12.3))
            XCTAssertEqual(arguments.last, .stringLiteral("monkey"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
