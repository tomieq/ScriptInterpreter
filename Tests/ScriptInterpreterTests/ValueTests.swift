//
//  ValueTests.swift
//
//
//  Created by Tomasz Kucharski on 30/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class ValueTests: XCTestCase {
    func test_interpolateValue() {
        let text = "I'm \\(age) years old and I'm \\(mood)"
        let variableRegistry = VariableRegistry()
        XCTAssertNoThrow(try variableRegistry.registerVariable(name: "age", variable: .primitive(.integer(38))))
        XCTAssertNoThrow(try variableRegistry.registerVariable(name: "mood", variable: .primitive(.string("happy"))))
        let interpolated = try? Value.string(text).interpolated(with: variableRegistry).description
        XCTAssertEqual(interpolated, "I'm 38 years old and I'm happy")
    }
}
