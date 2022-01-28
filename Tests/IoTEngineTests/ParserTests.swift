//
//  ParserTests.swift
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import XCTest
@testable import IoTEngine

class ParserTests: XCTestCase {


    func test_parsingAndCallingSimpleFunction() throws {
        
        let spy = FunctionCallSpy()
        let functionRegistry = FunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseByOne))
        
        do {
            let script = "increaseCounter()"
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.callCounter, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.callCounter, 1)
            
        } catch {
            
        }
    }
    
    func test_parsingAndCallingTwoFunctions() throws {
        
        let spy = FunctionCallSpy()
        let functionRegistry = FunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseByOne))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.increaseByTwo))
        

        let script = "increaseCounter() addTwo()"
        let lexer = try Lexer(code: script)
        let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
        let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry)
        XCTAssertEqual(spy.callCounter, 0)
        XCTAssertNoThrow(try parser.execute())
        XCTAssertEqual(spy.callCounter, 3)

    }
    
    func test_callFunctionWithBoolArgument() {
        let spy = FunctionCallSpy()
        let functionRegistry = FunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addValues", function: spy.addValues))
        
        let script = "addValues(true)"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.received.count, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.received.count, 1)
            XCTAssertTrue(spy.received.contains(Value.bool(true)))
        } catch {
            XCTAssert(false, error.localizedDescription)
        }
    }
}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    var received: [Value] = []
    
    func increaseByOne() {
        self.callCounter += 1
    }
    
    func increaseByTwo() {
        self.callCounter += 2
    }
    
    func addValues(_ data: [Value]) {
        self.received.append(contentsOf: data)
    }
}
