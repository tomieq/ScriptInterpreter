//
//  VariableParserTests.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class VariableParserTests: XCTestCase {

    func test_initNilVariable() {
        
        let script = "var distance;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertTrue(variableRegistry.valueExists(name: "distance"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initBoolVariable() {
        
        let script = "var agreed = false;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "agreed"), .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initIntegerVariable() {
        
        let script = "var weight = 82;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "weight"), .integer(82))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initStringVariable() {
        
        let script = "var name = \"Thomas\";"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "name"), .string("Thomas"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initFloatVariable() {
        
        let script = "var length = 50.9;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "length"), .float(50.9))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initMultipleNilVariables() {

        let script = "var milage, color, make;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertTrue(variableRegistry.valueExists(name: "milage"))
            XCTAssertTrue(variableRegistry.valueExists(name: "color"))
            XCTAssertTrue(variableRegistry.valueExists(name: "make"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initMixedVariables() {
        let script = "var age = 38, style, flag = true;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertTrue(variableRegistry.valueExists(name: "style"))
            XCTAssertEqual(variableRegistry.getValue(name: "age"), .integer(38))
            XCTAssertEqual(variableRegistry.getValue(name: "flag"), .bool(true))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initVariablesMultipleLines() {
        let script = "var color = \"red\"\nvar number = 13; var size = 8.9;\nvar flag = false;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "color"), .string("red"))
            XCTAssertEqual(variableRegistry.getValue(name: "number"), .integer(13))
            XCTAssertEqual(variableRegistry.getValue(name: "size"), .float(8.9))
            XCTAssertEqual(variableRegistry.getValue(name: "flag"), .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_assignVariableFromOtherVariable() {
        let script = "var age = 20; var ageCopy = age;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "age"), .integer(20))
            XCTAssertEqual(variableRegistry.getValue(name: "ageCopy"), .integer(20))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_leftTokens() {
        let script = "var age = 20, startTime = age; connect(8080); var finishTime = age; var ogr = 6"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "age"), .integer(20))
            let leftTokens = parser.leftTokens
            XCTAssertEqual(leftTokens.count, 5)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_internalFunctionVariablesAreOmmited() {
        let script = "var temperature = 21.4; function disable() { var flag = false; }"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let variableRegistry = VariableRegistry()
            XCTAssertNoThrow(try parser.parse(into: variableRegistry))
            XCTAssertEqual(variableRegistry.getValue(name: "temperature"), .float(21.4))
            XCTAssertFalse(variableRegistry.valueExists(name: "flag"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
