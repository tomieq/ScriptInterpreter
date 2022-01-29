//
//  ParserTests.swift
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import XCTest
@testable import IoTEngine

class ParserTests: XCTestCase {

    func test_callingExternalFunctionWithoutArgs() throws {
        
        let spy = self.setupSpy(code: "increaseCounter()")
        XCTAssertEqual(spy.callCounter, 1)
    }
    
    func test_callingTwoExternalFunctions() throws {
        
        let spy = self.setupSpy(code: "increaseCounter() addTwo()")
        XCTAssertEqual(spy.callCounter, 3)
    }
    
    func test_callExternalFunctionWithArguments() {
        let spy = self.setupSpy(code: "print(true, 20, 'works', 3.14)")
        XCTAssertEqual(spy.output.count, 4)
        XCTAssertEqual(spy.output[safeIndex: 0], .bool(true))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(20))
        XCTAssertEqual(spy.output[safeIndex: 2], .string("works"))
        XCTAssertEqual(spy.output[safeIndex: 3], .float(3.14))
    }
    
    func test_callExternalFunctionWithVariableValue() {
        let spy = self.setupSpy(code: "var number = 55; print(number);")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(55))
    }
    
    func test_ifElseStatementTrue() {
        let spy = self.setupSpy(code: "var execute = true; if(execute) { print(20) } else { print(21); }")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(20))
    }
    
    func test_ifElseStatementFalse() {
        let spy = self.setupSpy(code: "var execute = false; if(execute) { print(20) } else { print(21, 22); }")
        XCTAssertEqual(spy.output.count, 2)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(21))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(22))
    }
    
    func test_variableNamespaceIfStatement() {
        let spy = self.setupSpy(code: "var execute = true; var amount = 5 ; if(execute) { print(amount) } else { print(21); }")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(5))
    }
    
    func test_variableNamespaceElseStatement() {
        let spy = self.setupSpy(code: "var execute = false; var amount = 5 ; if(execute) { print(50) } else { print(amount); }")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(5))
    }
    
    func test_variableLocalNamespace() {
        let spy = self.setupSpy(code: "var execute = true; var amount = 5 ; if(execute) { var amount = 10; print(amount) } print(amount);")
        XCTAssertEqual(spy.output.count, 2)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(10))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(5))
    }
    
    private func setupSpy(code: String) -> FunctionCallSpy {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseCounter))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.addTwo))
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertNoThrow(try parser.execute())
        } catch {
            XCTFail(error.localizedDescription)
        }
        return spy
    }
}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    var output: [Value] = []
    
    func increaseCounter() {
        self.callCounter += 1
    }
    
    func addTwo() {
        self.callCounter += 2
    }
    
    func print(_ data: [Value]) {
        self.output.append(contentsOf: data)
    }
}
