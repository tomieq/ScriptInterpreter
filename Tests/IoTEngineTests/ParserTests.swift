//
//  ParserTests.swift
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import XCTest
@testable import IoTEngine

class ParserTests: XCTestCase {

    func test_callingExternalFunctionWithoutArgs() throws {
        
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseByOne))
        
        do {
            let script = "increaseCounter()"
            let lexer = try Lexer(code: script)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.callCounter, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.callCounter, 1)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_callingTwoExternalFunctions() throws {
        
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseByOne))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.increaseByTwo))
        

        let script = "increaseCounter() addTwo()"
        let lexer = try Lexer(code: script)
        let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
        XCTAssertEqual(spy.callCounter, 0)
        XCTAssertNoThrow(try parser.execute())
        XCTAssertEqual(spy.callCounter, 3)

    }
    
    func test_callExternalFunctionWithArguments() {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        
        let script = "print(true, 20, 'works', 3.14)"
        do {
            let lexer = try Lexer(code: script)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.output.count, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.output.count, 4)
            XCTAssertEqual(spy.output[safeIndex: 0], .bool(true))
            XCTAssertEqual(spy.output[safeIndex: 1], .integer(20))
            XCTAssertEqual(spy.output[safeIndex: 2], .string("works"))
            XCTAssertEqual(spy.output[safeIndex: 3], .float(3.14))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_callExternalFunctionWithVariableValue() {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        
        let script = "var number = 55; print(number);"
        do {
            let lexer = try Lexer(code: script)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.output.count, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.output.count, 1)
            XCTAssertEqual(spy.output[safeIndex: 0], .integer(55))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_ifElseStatementTrue() {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        
        let script = "var execute = true; if(execute) { print(20) } else { print(21); }"
        do {
            let lexer = try Lexer(code: script)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.output.count, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.output.count, 1)
            XCTAssertEqual(spy.output[safeIndex: 0], .integer(20))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_ifElseStatementFalse() {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        
        let script = "var execute = false; if(execute) { print(20) } else { print(21, 22); }"
        do {
            let lexer = try Lexer(code: script)
            let parser = Parser(tokens: lexer.tokens, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.output.count, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.output.count, 2)
            XCTAssertEqual(spy.output[safeIndex: 0], .integer(21))
            XCTAssertEqual(spy.output[safeIndex: 1], .integer(22))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    var output: [Value] = []
    
    func increaseByOne() {
        self.callCounter += 1
    }
    
    func increaseByTwo() {
        self.callCounter += 2
    }
    
    func print(_ data: [Value]) {
        self.output.append(contentsOf: data)
    }
}
