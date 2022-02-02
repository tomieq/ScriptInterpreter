//
//  FunctionParserTests.swift
//  
//
//  Created by Tomasz Kucharski on 02/02/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class FunctionParserTests: XCTestCase {
    
    func test_emptyFunctionWithoutArguments() {
        let functionRegistry = self.getFunctionRegistry(code: "func rotate() { }")
        let function = functionRegistry.getFunction(name: "rotate")
        XCTAssertNotNil(function)
        XCTAssertEqual(function?.name, "rotate")
        XCTAssertEqual(function?.argumentNames, [])
        XCTAssertEqual(function?.body, [])
    }
    
    private func getFunctionRegistry(code: String) -> LocalFunctionRegistry {
        let functionRegistry = LocalFunctionRegistry()
        do{
            let lexer = try Lexer(code: code)
            let parser = FunctionParser(tokens: lexer.tokens)
            XCTAssertNoThrow(try parser.parse(functionTokenIndex: 0, into: functionRegistry))
        } catch {
            XCTFail(error.localizedDescription)
        }
        return functionRegistry
    }
}
