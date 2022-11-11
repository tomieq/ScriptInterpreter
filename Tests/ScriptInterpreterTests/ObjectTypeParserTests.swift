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
    var registerSet: RegisterSet {
        RegisterSet(variableRegistry: VariableRegistry(),
                    localFunctionRegistry: LocalFunctionRegistry(),
                    externalFunctionRegistry: ExternalFunctionRegistry(),
                    objectTypeRegistry: ObjectTypeRegistry())
    }

    func test_parseEmptyClassBody() {
        let script = "class User {}"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            XCTAssertNotNil(registry.getObjectType("User"))
            XCTAssertEqual(consumedTokens, 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassBodyWithMethodWithoutArguments() {
        let script = "class User { func isWorking() { return false } }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            let method = objectType?.methodsRegistry.getFunction(name: "isWorking")
            XCTAssertNotNil(method)
            XCTAssertEqual(method?.body, [.return, .boolLiteral(false)])
            XCTAssertEqual(consumedTokens, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassBodyWithMethodWithArguments() {
        let script = "class User { func setAge(number) { return false } }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            let method = objectType?.methodsRegistry.getFunction(name: "setAge")
            XCTAssertNotNil(method)
            XCTAssertEqual(method?.argumentNames, ["number"])
            XCTAssertEqual(consumedTokens, 12)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassBodyWithMultipleMethods() {
        let script = "class User { func setAge(number) { return false } func meow() { print('meow') } }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            XCTAssertNoThrow(try parser.parse(objectTypeDefinitionIndex: 0, into: registry))
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            XCTAssertNotNil(objectType?.methodsRegistry.getFunction(name: "setAge"))
            XCTAssertNotNil(objectType?.methodsRegistry.getFunction(name: "meow"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassWithAttributes() {
        let script = "class User { var age = 38; }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            XCTAssertNoThrow(try parser.parse(objectTypeDefinitionIndex: 0, into: registry))
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            let attribute = objectType?.attributesRegistry.getVariable(name: "age")
            XCTAssertNotNil(attribute)
            XCTAssertEqual(attribute?.primitive, .integer(38))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassBodyWithSwiftConstructor() {
        let script = "class User { init() { return false } }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            let method = objectType?.methodsRegistry.getFunction(name: "init")
            XCTAssertNotNil(method)
            XCTAssertEqual(method?.body, [.return, .boolLiteral(false)])
            XCTAssertEqual(consumedTokens, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassBodyWithSwiftConstructorWithArguments() {
        let script = "class User { init(name) { return name } }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            let method = objectType?.methodsRegistry.getFunction(name: "init")
            XCTAssertNotNil(method)
            XCTAssertEqual(method?.argumentNames, ["name"])
            XCTAssertEqual(method?.body, [.return, .variable(name: "name")])
            XCTAssertEqual(consumedTokens, 12)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_parseClassBodyWithJavaScriptConstructor() {
        let script = "class User { constructor() { return false } }"
        do {
            let lexer = try Lexer(code: script)
            let parser = ObjectTypeParser(tokens: lexer.tokens, registerSet: self.registerSet)
            let registry = ObjectTypeRegistry()
            let consumedTokens = try parser.parse(objectTypeDefinitionIndex: 0, into: registry)
            let objectType = registry.getObjectType("User")
            XCTAssertNotNil(objectType)
            let method = objectType?.methodsRegistry.getFunction(name: "init")
            XCTAssertNotNil(method)
            XCTAssertEqual(method?.body, [.return, .boolLiteral(false)])
            XCTAssertEqual(consumedTokens, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
