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
        let functionRegistry = ExternalFunctionRegistry()
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
        let functionRegistry = ExternalFunctionRegistry()
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
        let functionRegistry = ExternalFunctionRegistry()
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
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertTrue(valueRegistry.valueExists(name: "distance"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initBoolVariable() {
        
        let script = "var agreed = false;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(valueRegistry.getValue(name: "agreed"), .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initIntegerVariable() {
        
        let script = "var weight = 82;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(valueRegistry.getValue(name: "weight"), .integer(82))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initStringVariable() {
        
        let script = "var name = \"Thomas\";"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(valueRegistry.getValue(name: "name"), .string("Thomas"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initFloatVariable() {
        
        let script = "var length = 50.9;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(valueRegistry.getValue(name: "length"), .float(50.9))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initMultipleNilVariables() {

        let script = "var milage, color, make;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertTrue(valueRegistry.valueExists(name: "milage"))
            XCTAssertTrue(valueRegistry.valueExists(name: "color"))
            XCTAssertTrue(valueRegistry.valueExists(name: "make"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initMixedVariables() {
        let script = "var age = 38, style, flag = true;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertTrue(valueRegistry.valueExists(name: "style"))
            XCTAssertEqual(valueRegistry.getValue(name: "age"), .integer(38))
            XCTAssertEqual(valueRegistry.getValue(name: "flag"), .bool(true))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initVariablesMultipleLines() {
        let script = "var color = \"red\"\nvar number = 13; var size = 8.9;\nvar flag = false;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(valueRegistry.getValue(name: "color"), .string("red"))
            XCTAssertEqual(valueRegistry.getValue(name: "number"), .integer(13))
            XCTAssertEqual(valueRegistry.getValue(name: "size"), .float(8.9))
            XCTAssertEqual(valueRegistry.getValue(name: "flag"), .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_assignVariableFromOtherVariable() {
        let script = "var age = 20; var ageCopy = age;"
        do {
            let lexer = try Lexer(code: script)
            let lexicalAnalizer = LexicalAnalyzer(lexer: lexer)
            let functionRegistry = ExternalFunctionRegistry()
            let valueRegistry = ValueRegistry()
            let parser = Parser(lexicalAnalizer: lexicalAnalizer, functionRegistry: functionRegistry, valueRegistry: valueRegistry)
            XCTAssertNoThrow(try parser.execute())
            XCTAssertEqual(valueRegistry.getValue(name: "age"), .integer(20))
            XCTAssertEqual(valueRegistry.getValue(name: "ageCopy"), .integer(20))
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
