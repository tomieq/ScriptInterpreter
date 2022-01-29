//
//  ConditionEvaluatorTests.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class ConditionEvaluatorTests: XCTestCase {
    
    func test_emptyCondition() {
        let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
        XCTAssertThrowsError(try evaluator.check(tokens: []))
    }
    
    func test_boolLiteral() {
        XCTAssertNoThrow(try self.checkTrue(code: "true"))
        XCTAssertNoThrow(try self.checkFalse(code: "false"))
    }
    
    func test_intLiteral() {
        XCTAssertNoThrow(try self.checkTrue(code: "10 == 10"))
        XCTAssertNoThrow(try self.checkFalse(code: "10 == 11"))
        XCTAssertNoThrow(try self.checkTrue(code: "10 != 11"))
        XCTAssertNoThrow(try self.checkFalse(code: "22 != 22"))
    }
    
    func test_stringLiteral() {
        XCTAssertNoThrow(try self.checkTrue(code: "'topic' == 'topic'"))
        XCTAssertNoThrow(try self.checkFalse(code: "'topic' == 'Topic'"))
        XCTAssertNoThrow(try self.checkTrue(code: "'macOS' != 'linux'"))
        XCTAssertNoThrow(try self.checkFalse(code: "'iOS' != 'iOS'"))
    }
    
    func test_integerLiteralWithVariable() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "distance", value: .integer(104))
        
        XCTAssertNoThrow(try self.checkTrue(code: "distance == 104", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "distance == 500", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "104 == distance", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "800 == distance", valueRegistry: valueRegistry))
    }

    func test_boolLiteralWithVariable() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "isSold", value: .bool(true))
        
        XCTAssertNoThrow(try self.checkTrue(code: "isSold == true", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "isSold == false", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "true == isSold", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "false == isSold", valueRegistry: valueRegistry))
    }

    func test_stringLiteralWithVariable() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "label", value: .string("damaged"))
        
        XCTAssertNoThrow(try self.checkTrue(code: "label == 'damaged'", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "label == 'installed'", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "'damaged' == label", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "'brother' == label", valueRegistry: valueRegistry))
    }

    func test_floatLiteralWithVariable() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "pi", value: .float(3.14))
        
        XCTAssertNoThrow(try self.checkTrue(code: "pi == 3.14", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "pi == 6.20", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "3.14 == pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "9.0 == pi", valueRegistry: valueRegistry))
    }
    
    func test_compareTwoVariables() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "max", value: .integer(100))
        valueRegistry.registerValue(name: "current_1", value: .integer(73))
        valueRegistry.registerValue(name: "current_2", value: .integer(100))

        XCTAssertNoThrow(try self.checkTrue(code: "max != current_1", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "max == current_1", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "max == current_2", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "max != current_2", valueRegistry: valueRegistry))
        
    }
    
    func test_lessComparator() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "min", value: .integer(11))
        valueRegistry.registerValue(name: "max", value: .integer(87))
        valueRegistry.registerValue(name: "pi", value: .float(3.14))
        valueRegistry.registerValue(name: "e", value: .float(2.71))

        XCTAssertNoThrow(try self.checkTrue(code: "pi < 4.08", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "e < pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 < 1.0", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi < 4.0", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 < pi", valueRegistry: valueRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "2 < 10", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min < 12", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min < max", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0 < max", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "max < 0", valueRegistry: valueRegistry))
    }
    
    func test_graterComparator() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "min", value: .integer(11))
        valueRegistry.registerValue(name: "max", value: .integer(87))
        valueRegistry.registerValue(name: "pi", value: .float(3.14))
        valueRegistry.registerValue(name: "e", value: .float(2.71))

        XCTAssertNoThrow(try self.checkTrue(code: "4.08 > pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi > e", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.0 > 0.13", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "4.0 > pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi > 3.0", valueRegistry: valueRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "10 > 3", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "12 > min", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "max > min", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "max > 0", valueRegistry: valueRegistry))
    }
    
    func test_lessOrEqualComparator() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "min", value: .integer(11))
        valueRegistry.registerValue(name: "pi", value: .float(3.14))

        XCTAssertNoThrow(try self.checkTrue(code: "pi <= 4.08", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi <= 3.14", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 <= 1.0", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.1 <= 1.1", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 <= pi", valueRegistry: valueRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "2 <= 10", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "10 <= 10", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min <= 12", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min <= 11", valueRegistry: valueRegistry))
    }
    
    func test_greaterOrEqualComparator() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "min", value: .integer(11))
        valueRegistry.registerValue(name: "pi", value: .float(3.14))

        XCTAssertNoThrow(try self.checkTrue(code: "4.08 >= pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "3.14 >= pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.0 >= 0.12", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.1 >= 1.1", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi >= .13", valueRegistry: valueRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "10 >= 2", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "10 >= 10", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "12 >= min", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "11 >= min", valueRegistry: valueRegistry))
    }
    
    func test_validateErros() {
        let valueRegistry = ValueRegistry()
        valueRegistry.registerValue(name: "label", value: .string("damaged"))
        valueRegistry.registerValue(name: "pi", value: .float(3.14))
        valueRegistry.registerValue(name: "isSold", value: .bool(true))
        valueRegistry.registerValue(name: "distance", value: .integer(104))
        
        XCTAssertNoThrow(try self.checkThrowsError(code: "200", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "6.75", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "'engine'", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "label", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "distance", valueRegistry: valueRegistry))
        // invalid comparisons
        
        XCTAssertNoThrow(try self.checkThrowsError(code: "label == 300", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "300 == label", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "pi == 300", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "label == pi", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "isSold == 300", valueRegistry: valueRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "300 == isSold", valueRegistry: valueRegistry))
        
    }
    
    private func checkTrue(code: String, valueRegistry: ValueRegistry = ValueRegistry()) throws {
        let lexer = try Lexer(code: code)
        let evaluator = ConditionEvaluator(valueRegistry: valueRegistry)
        XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
    }
    
    private func checkFalse(code: String, valueRegistry: ValueRegistry = ValueRegistry()) throws {
        let lexer = try Lexer(code: code)
        let evaluator = ConditionEvaluator(valueRegistry: valueRegistry)
        XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
    }
    
    private func checkThrowsError(code: String, valueRegistry: ValueRegistry = ValueRegistry()) throws {
        let lexer = try Lexer(code: code)
        let evaluator = ConditionEvaluator(valueRegistry: valueRegistry)
        XCTAssertThrowsError(try evaluator.check(tokens: lexer.tokens))
    }
}
