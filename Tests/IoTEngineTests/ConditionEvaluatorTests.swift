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
}
