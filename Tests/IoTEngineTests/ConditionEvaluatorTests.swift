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
    
    func test_boolTrue() {
        let code = "true"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_boolFalse() {
        let code = "false"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerEqualsTrue() {
        let code = "10 == 10"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerEqualsFalse() {
        let code = "10 == 11"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerNotEqualsTrue() {
        let code = "10 != 11"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerNotEqualsFalse() {
        let code = "10 != 10"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_stringEqualsTrue() {
        let code = "\"piramids\" == \"piramids\""
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_stringEqualsFalse() {
        let code = "\"piramids\" == \"Piramids\""
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator(valueRegistry: ValueRegistry())
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_variableTrue() {
        let condition = "distance"
        do {
            let lexer = try Lexer(code: condition)
            let valueRegistry = ValueRegistry()
            valueRegistry.registerValue(name: "distance", value: .bool(true))
            let evaluator = ConditionEvaluator(valueRegistry: valueRegistry)
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_variableFalse() {
        let condition = "distance"
        do {
            let lexer = try Lexer(code: condition)
            let valueRegistry = ValueRegistry()
            valueRegistry.registerValue(name: "distance", value: .bool(false))
            let evaluator = ConditionEvaluator(valueRegistry: valueRegistry)
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
