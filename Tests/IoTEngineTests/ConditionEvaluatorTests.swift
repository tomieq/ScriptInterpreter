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
        let evaluator = ConditionEvaluator()
        XCTAssertThrowsError(try evaluator.check(tokens: []))
    }
    
    func test_boolTrue() {
        let code = "true"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_boolFalse() {
        let code = "false"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerEqualsTrue() {
        let code = "10 == 10"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerEqualsFalse() {
        let code = "10 == 11"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerNotEqualsTrue() {
        let code = "10 != 11"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_integerNotEqualsFalse() {
        let code = "10 != 10"
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_stringEqualsTrue() {
        let code = "\"piramids\" == \"piramids\""
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertTrue(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_stringEqualsFalse() {
        let code = "\"piramids\" == \"Piramids\""
        do {
            let lexer = try Lexer(code: code)
            let evaluator = ConditionEvaluator()
            XCTAssertFalse(try evaluator.check(tokens: lexer.tokens))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
