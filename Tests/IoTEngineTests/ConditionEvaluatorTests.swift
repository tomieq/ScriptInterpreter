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
        let evaluator = ConditionEvaluator(variableRegistry: VariableRegistry())
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
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "distance", value: .integer(104))
        
        XCTAssertNoThrow(try self.checkTrue(code: "distance == 104", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "distance == 500", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "104 == distance", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "800 == distance", variableRegistry: variableRegistry))
    }

    func test_boolLiteralWithVariable() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "isSold", value: .bool(true))
        
        XCTAssertNoThrow(try self.checkTrue(code: "isSold == true", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "isSold == false", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "true == isSold", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "false == isSold", variableRegistry: variableRegistry))
    }

    func test_stringLiteralWithVariable() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "label", value: .string("damaged"))
        
        XCTAssertNoThrow(try self.checkTrue(code: "label == 'damaged'", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "label == 'installed'", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "'damaged' == label", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "'brother' == label", variableRegistry: variableRegistry))
    }

    func test_floatLiteralWithVariable() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "pi", value: .float(3.14))
        
        XCTAssertNoThrow(try self.checkTrue(code: "pi == 3.14", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "pi == 6.20", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "3.14 == pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "9.0 == pi", variableRegistry: variableRegistry))
    }
    
    func test_compareTwoVariables() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "max", value: .integer(100))
        variableRegistry.registerValue(name: "current_1", value: .integer(73))
        variableRegistry.registerValue(name: "current_2", value: .integer(100))

        XCTAssertNoThrow(try self.checkTrue(code: "max != current_1", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "max == current_1", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "max == current_2", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "max != current_2", variableRegistry: variableRegistry))
        
    }
    
    func test_lessComparator() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "min", value: .integer(11))
        variableRegistry.registerValue(name: "max", value: .integer(87))
        variableRegistry.registerValue(name: "pi", value: .float(3.14))
        variableRegistry.registerValue(name: "e", value: .float(2.71))

        XCTAssertNoThrow(try self.checkTrue(code: "pi < 4.08", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "e < pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 < 1.0", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi < 4.0", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 < pi", variableRegistry: variableRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "2 < 10", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min < 12", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min < max", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0 < max", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkFalse(code: "max < 0", variableRegistry: variableRegistry))
    }
    
    func test_graterComparator() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "min", value: .integer(11))
        variableRegistry.registerValue(name: "max", value: .integer(87))
        variableRegistry.registerValue(name: "pi", value: .float(3.14))
        variableRegistry.registerValue(name: "e", value: .float(2.71))

        XCTAssertNoThrow(try self.checkTrue(code: "4.08 > pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi > e", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.0 > 0.13", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "4.0 > pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi > 3.0", variableRegistry: variableRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "10 > 3", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "12 > min", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "max > min", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "max > 0", variableRegistry: variableRegistry))
    }
    
    func test_lessOrEqualComparator() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "min", value: .integer(11))
        variableRegistry.registerValue(name: "pi", value: .float(3.14))

        XCTAssertNoThrow(try self.checkTrue(code: "pi <= 4.08", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi <= 3.14", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 <= 1.0", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.1 <= 1.1", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "0.12 <= pi", variableRegistry: variableRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "2 <= 10", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "10 <= 10", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min <= 12", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "min <= 11", variableRegistry: variableRegistry))
    }
    
    func test_greaterOrEqualComparator() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "min", value: .integer(11))
        variableRegistry.registerValue(name: "pi", value: .float(3.14))

        XCTAssertNoThrow(try self.checkTrue(code: "4.08 >= pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "3.14 >= pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.0 >= 0.12", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "1.1 >= 1.1", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "pi >= .13", variableRegistry: variableRegistry))
        
        XCTAssertNoThrow(try self.checkTrue(code: "10 >= 2", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "10 >= 10", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "12 >= min", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkTrue(code: "11 >= min", variableRegistry: variableRegistry))
    }
    
    func test_validateErros() {
        let variableRegistry = VariableRegistry()
        variableRegistry.registerValue(name: "label", value: .string("damaged"))
        variableRegistry.registerValue(name: "pi", value: .float(3.14))
        variableRegistry.registerValue(name: "isSold", value: .bool(true))
        variableRegistry.registerValue(name: "distance", value: .integer(104))
        
        XCTAssertNoThrow(try self.checkThrowsError(code: "200", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "6.75", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "'engine'", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "label", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "distance", variableRegistry: variableRegistry))
        // invalid comparisons
        
        XCTAssertNoThrow(try self.checkThrowsError(code: "label == 300", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "300 == label", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "pi == 300", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "label == pi", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "isSold == 300", variableRegistry: variableRegistry))
        XCTAssertNoThrow(try self.checkThrowsError(code: "300 == isSold", variableRegistry: variableRegistry))
        
    }
    
    private func checkTrue(code: String, variableRegistry: VariableRegistry = VariableRegistry()) throws {
        let lexer = try Lexer(code: code)
        let evaluator = ConditionEvaluator(variableRegistry: variableRegistry)
        XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
    }
    
    private func checkFalse(code: String, variableRegistry: VariableRegistry = VariableRegistry()) throws {
        let lexer = try Lexer(code: code)
        let evaluator = ConditionEvaluator(variableRegistry: variableRegistry)
        XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
    }
    
    private func checkThrowsError(code: String, variableRegistry: VariableRegistry = VariableRegistry()) throws {
        let lexer = try Lexer(code: code)
        let evaluator = ConditionEvaluator(variableRegistry: variableRegistry)
        XCTAssertThrowsError(try evaluator.check(tokens: lexer.tokens))
    }
}
