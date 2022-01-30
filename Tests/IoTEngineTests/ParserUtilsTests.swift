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
        let variableRegistry = VariableRegistry()
        let value = ParserUtils.token2Value(.intLiteral(45), variableRegistry: variableRegistry)
        XCTAssertEqual(value, .integer(45))
    }
    
    func test_convertBoolTokenToValue() {
        let variableRegistry = VariableRegistry()
        let value = ParserUtils.token2Value(.boolLiteral(true), variableRegistry: variableRegistry)
        XCTAssertEqual(value, .bool(true))
    }
    
    func test_convertFloatTokenToValue() {
        let variableRegistry = VariableRegistry()
        let value = ParserUtils.token2Value(.floatLiteral(9.12), variableRegistry: variableRegistry)
        XCTAssertEqual(value, .float(9.12))
    }
    
    func test_convertStringTokenToValue() {
        let variableRegistry = VariableRegistry()
        let value = ParserUtils.token2Value(.stringLiteral("hello world"), variableRegistry: variableRegistry)
        XCTAssertEqual(value, .string("hello world"))
    }
    
    func test_convertVariableTokenToValue() {
        let variableRegistry = VariableRegistry()
        XCTAssertNoThrow(try variableRegistry.registerValue(name: "data", value: .integer(1985)))
        let value = ParserUtils.token2Value(.variable(name: "data"), variableRegistry: variableRegistry)
        XCTAssertEqual(value, .integer(1985))
    }
    
    func test_getTokensBetweenBracketsNoNested() {
        let code = " open(10, false, 1.0)\n data = 50;"
        do {
            let lexer = try Lexer(code: code)
            let tokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: 1, tokens: lexer.tokens)
            XCTAssertEqual(tokens.count, 5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_getTokensBetweenBracketsNestedBrackets() {
        let code = "var age = ( 1 + 5 + (10 - 4) )"
        do {
            let lexer = try Lexer(code: code)
            let tokens = try ParserUtils.getTokensBetweenBrackets(indexOfOpeningBracket: 3, tokens: lexer.tokens)
            XCTAssertEqual(tokens.count, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_getTokensInBlockNoNested() {
        let code = "var age = 80; function exec() { var lenght = 122.8 }"
        do {
            let lexer = try Lexer(code: code)
            let tokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: 7, tokens: lexer.tokens)
            XCTAssertEqual(tokens.count, 4)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_getTokensInBlockNestedData() {
        let code = "function exec() { var lenght = 122.8 if(true) { print(100) } }"
        do {
            let lexer = try Lexer(code: code)
            let tokens = try ParserUtils.getTokensForBlock(indexOfOpeningBlock: 2, tokens: lexer.tokens)
            XCTAssertEqual(tokens.count, 14)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
