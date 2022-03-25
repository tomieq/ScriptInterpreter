//
//  ObjectTypeParserTests.swift
//  
//
//  Created by Tomasz on 25/03/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class ObjectTypeParserTests: XCTestCase {
    func test_parseEmptyClassBody() {
        let script = "class User {}"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            XCTAssertNotNil(registry.getObjectType("User"))
            XCTAssertEqual(consumedTokens, 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
