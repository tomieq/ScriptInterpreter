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
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertEqual(spy.callCounter, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.callCounter, 1)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_parsingAndCallingTwoFunctions() throws {
        
        let spy = FunctionCallSpy()
        let functionRegistry = FunctionRegistry()
        let valueRegistry = ValueRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseByOne))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.increaseByTwo))
        

        let script = "increaseCounter() addTwo()"
        let lexer = try Lexer(code: script)
        let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
        let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
        XCTAssertEqual(spy.callCounter, 0)
        XCTAssertNoThrow(try parser.execute())
        XCTAssertEqual(spy.callCounter, 3)

    }
    
    func test_callFunctionWithBoolArgument() {
        let spy = FunctionCallSpy()
        let functionRegistry = FunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addValues", function: spy.addValues))
        
        let script = "addValues(true, 20, 'works', 3.14)"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertEqual(spy.received.count, 0)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(spy.received.count, 4)
            XCTAssertEqual(spy.received[safeIndex: 0], .bool(true))
            XCTAssertEqual(spy.received[safeIndex: 1], .integer(20))
            XCTAssertEqual(spy.received[safeIndex: 2], .string("works"))
            XCTAssertEqual(spy.received[safeIndex: 3], .float(3.14))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initNilVariable() {
        
        let script = "var distance;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = FunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertTrue(valueRegistry.valueExists(name: "distance"))
        } catch {
            XCTFail(error.localizedDescription)
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
