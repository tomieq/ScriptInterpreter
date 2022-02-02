//
//  TokenTests.swift
//  
//
//  Created by Tomasz Kucharski on 02/02/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class TokenTests: XCTestCase {
    
    func test_isLiteral() {
        XCTAssertEqual(Token.intLiteral(12).isLiteral, true)
        XCTAssertEqual(Token.boolLiteral(false).isLiteral, true)
        XCTAssertEqual(Token.stringLiteral("false").isLiteral, true)
        XCTAssertEqual(Token.floatLiteral(0).isLiteral, true)
        XCTAssertEqual(Token.bracketOpen.isLiteral, false)
    }
    
    func test_isFunction() {
        XCTAssertEqual(Token.function(name: "open").isFunction, true)
        XCTAssertEqual(Token.functionWithArguments(name: "open").isFunction, true)
        XCTAssertEqual(Token.functionDefinition(type: "func").isFunction, false)
        
    }
}
