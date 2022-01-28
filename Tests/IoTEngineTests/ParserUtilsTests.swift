//
//  ParserUtilsTests.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class ParserUtilsTests: XCTestCase {
    
    func test_convertIntTokenToValue() {
        let valueRegistry = ValueRegistry()
        let value = ParserUtils.token2Value(.intLiteral(45), valueRegistry: valueRegistry)
        XCTAssertEqual(value, .integer(45))
    }
    
    func test_convertBoolTokenToValue() {
        let valueRegistry = ValueRegistry()
        let value = ParserUtils.token2Value(.boolLiteral(true), valueRegistry: valueRegistry)
        XCTAssertEqual(value, .bool(true))
    }
    
    func test_convertFloatTokenToValue() {
        let valueRegistry = ValueRegistry()
        let value = ParserUtils.token2Value(.floatLiteral(9.12), valueRegistry: valueRegistry)
        XCTAssertEqual(value, .float(9.12))
    }
    
    func test_convertStringTokenToValue() {
        let valueRegistry = ValueRegistry()
        let value = ParserUtils.token2Value(.stringLiteral("hello world"), valueRegistry: valueRegistry)
        XCTAssertEqual(value, .string("hello world"))
    }
    
    func test_convertVariableTokenToValue() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "data", value: .integer(1985))
        let value = ParserUtils.token2Value(.variable(name: "data"), valueRegistry: valueRegistry)
        XCTAssertEqual(value, .integer(1985))
    }
    
    func test_getTokensBetweenBracketsNoNested() {
        let code = " open(10, false, 1.0)\n data = 50;"
        do {
            let lexer = try Lexer(code: code)
            print(lexer.tokens)
            let tokens = ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: 1, tokens: lexer.tokens)
            XCTAssertEqual(tokens.count, 5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
