//
//  ArithmeticCalculatorTests.swift
//
//
//  Created by Tomasz KUCHARSKI on 10/11/2022.
//

import XCTest
@testable import ScriptInterpreter

final class ArithmeticCalculatorTests: XCTestCase {
    func testSingleIntegerToken2Value() throws {
        let sut = try self.makeSUT("5")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 1)
        XCTAssertEqual(result.value, .integer(5))
    }

    func testSingleFloatToken2Value() throws {
        let sut = try self.makeSUT("5.5")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 1)
        XCTAssertEqual(result.value, .float(5.5))
    }

    func testSingleBoolToken2Value() throws {
        let sut = try self.makeSUT("false")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 1)
        XCTAssertEqual(result.value, .bool(false))
    }

    func testSingleStringToken2Value() throws {
        let code = """
            "tekst"
        """
        let sut = try self.makeSUT(code)
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 1)
        XCTAssertEqual(result.value, .string("tekst"))
    }

    func testSingleVariableToken2Value() throws {
        let sut = try self.makeSUT("age")
        try sut.registerSet.variableRegistry.registerVariable(name: "age", variable: .primitive(.integer(3)))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 1)
        XCTAssertEqual(result.value, .integer(3))
    }

    // MARK: integers
    func testAddingTwoIntegers() throws {
        let sut = try self.makeSUT("5 + 2")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 3)
        XCTAssertEqual(result.value, .integer(7))
    }

    func testAddingThreeIntegers() throws {
        let sut = try self.makeSUT("31 + 70 + 19;")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .integer(120))
    }

    func testSubtractTwoIntegers() throws {
        let sut = try self.makeSUT("8 - 6")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 3)
        XCTAssertEqual(result.value, .integer(2))
    }

    func testSubtractThreeIntegers() throws {
        let sut = try self.makeSUT("92 - 12 - 50")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .integer(30))
    }

    func testMultipleIntegerOperations() throws {
        let sut = try self.makeSUT("10 + 23 - 8")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .integer(25))
    }

    // MARK: floats
    func testAddingTwoFloats() throws {
        let sut = try self.makeSUT("5.1 + 2.3")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 3)
        XCTAssertEqual(result.value, .float(7.4))
    }

    func testAddingThreeFloats() throws {
        let sut = try self.makeSUT("31.1 + 70.6 + 19.2;")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .float(120.9))
    }

    func testSubtractTwoFloats() throws {
        let sut = try self.makeSUT("8.5 - 6.2")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 3)
        XCTAssertEqual(result.value, .float(2.3))
    }

    func testSubtractThreeFloats() throws {
        let sut = try self.makeSUT("92.9 - 12.5 - 50.3")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .float(30.1))
    }

    func testMultipleFloatOperations() throws {
        let sut = try self.makeSUT("10.3 + 23.1 - 8.1")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .float(25.3))
    }

    func testConcatenateStrings() throws {
        let code = """
            "hello" + " " + "world";
        """
        let sut = try self.makeSUT(code)
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .string("hello world"))
    }

    func testConcatenateStringsWithInterpolation() throws {
        let code = """
            "hello" + " " + "world\\(number)";
        """
        let sut = try self.makeSUT(code)
        try sut.registerSet.variableRegistry.registerVariable(name: "number", variable: .primitive(.integer(22)))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .string("hello world22"))
    }

    func testBooleanConditions() throws {
        // works the same like in ConditionEvaluatorTests
        let sut = try self.makeSUT("20 < 21 && 3.14 < 2.0")
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 7)
        XCTAssertEqual(result.value, .bool(false))
    }

    func testResolvingLocalFunction() throws {
        let sut = try self.makeSUT("50 + nine() - two()")
        sut.registerSet.localFunctionRegistry.register(LocalFunction(name: "nine", argumentNames: [], body: [.return, .intLiteral(9)]))
        sut.registerSet.localFunctionRegistry.register(LocalFunction(name: "two", argumentNames: [], body: [.return, .intLiteral(2)]))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .integer(57))
    }

    func testResolvingLocalFunctionReversed() throws {
        let sut = try self.makeSUT("nine() - two() + 50")
        sut.registerSet.localFunctionRegistry.register(LocalFunction(name: "nine", argumentNames: [], body: [.return, .intLiteral(9)]))
        sut.registerSet.localFunctionRegistry.register(LocalFunction(name: "two", argumentNames: [], body: [.return, .intLiteral(2)]))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 5)
        XCTAssertEqual(result.value, .integer(57))
    }

    func testResolvingLocalFunctionWithArguments() throws {
        let sut = try self.makeSUT("12 + number(2 + 11)")
        sut.registerSet.localFunctionRegistry.register(LocalFunction(name: "number", argumentNames: ["x"], body: [.return, .variable(name: "x")]))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 8)
        XCTAssertEqual(result.value, .integer(25))
    }

    func testResolvingExternalFunction() throws {
        func number() -> Value {
            .integer(5)
        }
        let sut = try self.makeSUT("12 + number()")
        try sut.registerSet.externalFunctionRegistry.registerFunc(name: "number", function: number)
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 3)
        XCTAssertEqual(result.value, .integer(17))
    }

    func testResolvingExternalFunctionWithArguments() throws {
        func number(_ values: [Value]) -> Value {
            values.first!
        }
        let sut = try self.makeSUT("12 + number(2 + 1)")
        try sut.registerSet.externalFunctionRegistry.registerFunc(name: "number", function: number)
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 8)
        XCTAssertEqual(result.value, .integer(15))
    }

    func testResolvingClassMethodCall() throws {
        let sut = try self.makeSUT("10 + computer.ram()")
        let objectMethods = LocalFunctionRegistry()
        objectMethods.register(LocalFunction(name: "ram", argumentNames: [], body: [.return, .intLiteral(8)]))
        sut.registerSet.objectTypeRegistry.register(objectType: ObjectType(name: "Computer",
                                                                           attributesRegistry: VariableRegistry(),
                                                                           methodsRegistry: objectMethods))
        try sut.registerSet.variableRegistry.registerVariable(name: "computer",
                                                              variable: .class(type: "Computer", attributesRegistry: VariableRegistry()))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 4)
        XCTAssertEqual(result.value, .integer(18))
    }

    func testResolvingClassMethodCallReversed() throws {
        let sut = try self.makeSUT("computer.ram() + 10")
        let objectMethods = LocalFunctionRegistry()
        objectMethods.register(LocalFunction(name: "ram", argumentNames: [], body: [.return, .intLiteral(8)]))
        sut.registerSet.objectTypeRegistry.register(objectType: ObjectType(name: "Computer",
                                                                           attributesRegistry: VariableRegistry(),
                                                                           methodsRegistry: objectMethods))
        try sut.registerSet.variableRegistry.registerVariable(name: "computer",
                                                              variable: .class(type: "Computer", attributesRegistry: VariableRegistry()))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 4)
        XCTAssertEqual(result.value, .integer(18))
    }

    func testResolvingClassMethodCallWithArguments() throws {
        let sut = try self.makeSUT("10 + computer.ram(64)")
        let objectMethods = LocalFunctionRegistry()
        objectMethods.register(LocalFunction(name: "ram", argumentNames: ["x"], body: [.return, .variable(name: "x")]))
        sut.registerSet.objectTypeRegistry.register(objectType: ObjectType(name: "Computer",
                                                                           attributesRegistry: VariableRegistry(),
                                                                           methodsRegistry: objectMethods))
        try sut.registerSet.variableRegistry.registerVariable(name: "computer",
                                                              variable: .class(type: "Computer", attributesRegistry: VariableRegistry()))
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 7)
        XCTAssertEqual(result.value, .integer(74))
    }

    func testRecognisingEndOfOperations() throws {
        func number(_ values: [Value]) -> Value {
            values.first!
        }
        let code = """
                12
                number(3)
        """
        let sut = try self.makeSUT(code)
        try sut.registerSet.externalFunctionRegistry.registerFunc(name: "number", function: number)
        let result = try sut.calculateValue(startIndex: 0)
        XCTAssertEqual(result.consumedTokens, 1)
        XCTAssertEqual(result.value, .integer(12))
    }

    private func makeSUT(_ code: String) throws -> ArithmeticCalculator {
        let lexer = try Lexer(code: code)
        let registerSet = RegisterSet(variableRegistry: VariableRegistry(),
                                      localFunctionRegistry: LocalFunctionRegistry(),
                                      externalFunctionRegistry: ExternalFunctionRegistry(),
                                      objectTypeRegistry: ObjectTypeRegistry())
        return ArithmeticCalculator(tokens: lexer.tokens, registerSet: registerSet)
    }
}
