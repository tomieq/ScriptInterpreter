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
}
