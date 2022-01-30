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
        let spy = self.setupSpy(code: "var execute = true; var amount = 5 ; if(execute) { let amount = false; print(amount) } print(amount);")
        XCTAssertEqual(spy.output.count, 2)
        XCTAssertEqual(spy.output[safeIndex: 0], .bool(false))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(5))
    }
    
    func test_sampleProgram() {
        let spy = self.setupSpy(code: "print(\"hello\"); print(\"world\"); var counter = 9; if ( counter == 9 ) { print('ok') } else { print('wrong') }")
        XCTAssertEqual(spy.output.count, 3)
        XCTAssertEqual(spy.output[safeIndex: 0], .string("hello"))
        XCTAssertEqual(spy.output[safeIndex: 1], .string("world"))
        XCTAssertEqual(spy.output[safeIndex: 2], .string("ok"))
        
        
        let console = self.setupSpy(code: "var counter = 12; if ( counter == 9 ) { print('the same') } else { print('different') }")
        XCTAssertEqual(console.output.count, 1)
        XCTAssertEqual(console.output[safeIndex: 0], .string("different"))
    }
    
    func test_assignVariable() {
        let console = self.setupSpy(code: "var age = 40; print(age); age = 50; print(age);")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(40))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(50))
        
        
        let console2 = self.setupSpy(code: "var min = 10; var max = 100; var current = 50; print(current); current = min; print(current);")
        XCTAssertEqual(console2.output.count, 2)
        XCTAssertEqual(console2.output[safeIndex: 0], .integer(50))
        XCTAssertEqual(console2.output[safeIndex: 1], .integer(10))
    }
    
    func test_breakStatement() {
        let console = self.setupSpy(code: "var age = 40; if(age == 40) { print('one'); break print('two') } print('three') break print('four')")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .string("one"))
        XCTAssertEqual(console.output[safeIndex: 1], .string("three"))
    }
    
    func test_variableIncrement() {
        let console = self.setupSpy(code: "var distance = 9; print(distance); distance++; print(distance)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(9))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(10))
    }
    
    func test_variableDecrement() {
        let console = self.setupSpy(code: "var distance = 9; print(distance); distance--; print(distance)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(9))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(8))
    }
    
    func test_whileLoop() {
        let console = self.setupSpy(code: "var i = 0; while(i < 5) { i++; print(i) }")
        XCTAssertEqual(console.output.count, 5)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 4], .integer(5))
    }

    func test_forLoop() {
        let console = self.setupSpy(code: "var i = 9; for(var i = 1; i <= 5; i++) { print(i) } print(i)")
        XCTAssertEqual(console.output.count, 6)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 4], .integer(5))
        XCTAssertEqual(console.output[safeIndex: 5], .integer(9))
    }

    func test_namespaceVariables() {
        let console = self.setupSpy(code: "var number = 0; print(number) { var number = 6; print(number) number--; print(number) } number++; print(number)")
        XCTAssertEqual(console.output.count, 4)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(0))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(6))
        XCTAssertEqual(console.output[safeIndex: 2], .integer(5))
        XCTAssertEqual(console.output[safeIndex: 3], .integer(1))
    }
    
    func test_updateConstant() {
        self.expectError(code: "let pi = 3.14; pi = 5.5")
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
    
    private func expectError(code: String) {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseCounter))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.addTwo))
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertThrowsError(try parser.execute())
        } catch {
            XCTFail(error.localizedDescription)
        }
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
