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
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
            XCTAssertTrue(valueRegistry.valueExists(name: "distance"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_initBoolVariable() {
        
        let script = "var agreed = false;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
            XCTAssertEqual(valueRegistry.getValue(name: "agreed"), .bool(false))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initIntegerVariable() {
        
        let script = "var weight = 82;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
            XCTAssertEqual(valueRegistry.getValue(name: "weight"), .integer(82))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initStringVariable() {
        
        let script = "var name = \"Thomas\";"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
            XCTAssertEqual(valueRegistry.getValue(name: "name"), .string("Thomas"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initFloatVariable() {
        
        let script = "var length = 50.9;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
            XCTAssertEqual(valueRegistry.getValue(name: "length"), .float(50.9))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_initMultipleNilVariables() {

        let script = "var milage, color, make;"
        do {
            let lexer = try Lexer(code: script)
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
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
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
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
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
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
            let parser = VariableParser(tokens: lexer.tokens)
            let valueRegistry = ValueRegistry()
            XCTAssertNoThrow(try parser.parse(into: valueRegistry))
            XCTAssertEqual(valueRegistry.getValue(name: "age"), .integer(20))
            XCTAssertEqual(valueRegistry.getValue(name: "ageCopy"), .integer(20))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
