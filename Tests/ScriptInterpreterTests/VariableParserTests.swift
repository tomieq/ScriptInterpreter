//
//  VariableParserTests.swift
//
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class VariableParserTests: XCTestCase {
    var registerSet: RegisterSet {
        RegisterSet(variableRegistry: VariableRegistry(),
                    localFunctionRegistry: LocalFunctionRegistry(),
                    externalFunctionRegistry: ExternalFunctionRegistry(),
                    objectTypeRegistry: ObjectTypeRegistry())
    }

    func test_initNilVariable() {
        let script = "var distance;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0))
            XCTAssertTrue(parser.registerSet.variableRegistry.variableExists(name: "distance"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initBoolVariable() {
        let script = "var agreed = false;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "agreed")?.primitive, .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initIntegerVariable() {
        let script = "var weight = 82;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "weight")?.primitive, .integer(82))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initStringVariable() {
        let script = "var name = \"Thomas\";"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "name")?.primitive, .string("Thomas"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initFloatVariable() {
        let script = "var length = 50.9;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "length")?.primitive, .float(50.9))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initMultipleNilVariables() {
        let script = "var milage, color, make;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0)
            XCTAssertTrue(parser.registerSet.variableRegistry.variableExists(name: "milage"))
            XCTAssertTrue(parser.registerSet.variableRegistry.variableExists(name: "color"))
            XCTAssertTrue(parser.registerSet.variableRegistry.variableExists(name: "make"))
            XCTAssertEqual(consumedTokens, 7)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initMixedVariables() {
        let script = "var age = 38, style, flag = true;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.parse(variableDefinitionIndex: 0))
            XCTAssertTrue(parser.registerSet.variableRegistry.variableExists(name: "style"))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "age")?.primitive, .integer(38))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "flag")?.primitive, .bool(true))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_assignVariableFromOtherVariable() {
        let script = "var ageCopy = age;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.registerSet.variableRegistry.registerVariable(name: "age", variable: .primitive(.integer(20))))
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0)
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "ageCopy")?.primitive, .integer(20))
            XCTAssertEqual(consumedTokens, 5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_assingVariableFromExternalFunction() throws {
        let script = "var age = getAge() + 1;"
        func getAge() -> Value {
            .integer(22)
        }
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(try parser.registerSet.externalFunctionRegistry.registerFunc(name: "getAge", function: getAge))
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0)
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "age")?.primitive, .integer(23))
            XCTAssertEqual(consumedTokens, 7)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_assingVariableFromInternalFunction() throws {
        let script = "var age = getAge() + 1;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            XCTAssertNoThrow(parser.registerSet.localFunctionRegistry.register(LocalFunction(name: "getAge",
                                                                                             argumentNames: [],
                                                                                             body: [.return, .intLiteral(10)])))
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0)
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "age")?.primitive, .integer(11))
            XCTAssertEqual(consumedTokens, 7)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_assingVariableFromClassAttribute() throws {
        let script = "var age = computer.ram print(90)"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let attributesRegistry = VariableRegistry()
            try attributesRegistry.registerVariable(name: "ram", variable: .primitive(.integer(128)))
            parser.registerSet.objectTypeRegistry.register(objectType: ObjectType(name: "Computer",
                                                                                  attributesRegistry: attributesRegistry, methodsRegistry: LocalFunctionRegistry()))
            try parser.registerSet.variableRegistry.registerVariable(name: "computer", variable: .class(type: "Computer",
                                                                                                        state: attributesRegistry))
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0)
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "age")?.primitive, .integer(128))
            XCTAssertEqual(consumedTokens, 5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_consumedTokens() {
        let script = "var age = 20, startTime = age;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let consumedTokens = try parser.parse(variableDefinitionIndex: 0)
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "age")?.primitive, .integer(20))
            XCTAssertEqual(parser.registerSet.variableRegistry.getVariable(name: "startTime")?.primitive, .integer(20))
            XCTAssertEqual(consumedTokens, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
