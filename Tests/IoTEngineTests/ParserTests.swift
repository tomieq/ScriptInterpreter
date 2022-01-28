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
            let parser = Parser(lexer: lexer, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.callCounter, 0)
            parser.execute()
            XCTAssertEqual(spy.callCounter, 1)
            
        } catch {
            
        }
    }
    
    func test_parsingAndCallingTwoFunctions() throws {
        
        let spy = FunctionCallSpy()
        let functionRegistry = FunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseByOne))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.increaseByTwo))
        
        do {
            let script = "increaseCounter() addTwo()"
            let lexer = try Lexer(code: script)
            let parser = Parser(lexer: lexer, functionRegistry: functionRegistry)
            XCTAssertEqual(spy.callCounter, 0)
            parser.execute()
            XCTAssertEqual(spy.callCounter, 3)
            
        } catch {
            
        }
    }
}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    
    func increaseByOne() {
        self.callCounter += 1
    }
    
    func increaseByTwo() {
        self.callCounter += 2
    }
}
