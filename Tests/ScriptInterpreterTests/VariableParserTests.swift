//
//  VariableParserTests.swift
//
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

fileprivate extension VariableRegistry {
    
    func getValue(name: String) -> Value? {
        guard let variable = self.getVariable(name: name) else { return nil }
        switch variable {
        case .primitive(let value):
            return value
        case .class(_, _):
            return nil
        }
    }
}

class VariableParserTests: XCTestCase {
    func test_initNilVariable() {
        let script = "var distance;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0, into: variableRegistry))
            XCTAssertTrue(variableRegistry.variableExists(name: "distance"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initBoolVariable() {
        let script = "var agreed = false;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0, into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "agreed"), .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initIntegerVariable() {
        let script = "var weight = 82;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0, into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "weight"), .integer(82))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initStringVariable() {
        let script = "var name = \"Thomas\";"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0, into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "name"), .string("Thomas"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initFloatVariable() {
        let script = "var length = 50.9;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0, into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "length"), .float(50.9))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initMultipleNilVariables() {
        let script = "var milage, color, make;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0, into: variableRegistry)
            XCTAssertTrue(variableRegistry.variableExists(name: "milage"))
            XCTAssertTrue(variableRegistry.variableExists(name: "color"))
            XCTAssertTrue(variableRegistry.variableExists(name: "make"))
            XCTAssertEqual(consumedTokens, 7)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initMixedVariables() {
        let script = "var age = 38, style, flag = true;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0, into: variableRegistry))
            XCTAssertTrue(variableRegistry.variableExists(name: "style"))
            XCTAssertEqual(variableRegistry.getValue(name: "age"), .integer(38))
            XCTAssertEqual(variableRegistry.getValue(name: "flag"), .bool(true))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_assignVariableFromOtherVariable() {
        let script = "var ageCopy = age;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try variableRegistry.registerVariable(name: "age", variable: .primitive(.integer(20))))
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0, into: variableRegistry)
            XCTAssertEqual(variableRegistry.getValue(name: "ageCopy"), .integer(20))
            XCTAssertEqual(consumedTokens, 5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_consumedTokens() {
        let script = "var age = 20, startTime = age;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0, into: variableRegistry)
            XCTAssertEqual(variableRegistry.getValue(name: "age"), .integer(20))
            XCTAssertEqual(consumedTokens, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
