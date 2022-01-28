//
//  ValueRegistryTests.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

final class ValueRegistryTests: XCTestCase {

    func test_registerNullVariable() {
        let registry = ValueRegistry()
        XCTAssertFalse(registry.valueExists(name: "amount"))
        registry.registerValue(name: "amount", value: nil)
        XCTAssertTrue(registry.valueExists(name: "amount"))
    }
    
    func test_registerNonNullVariable() {
        let registry = ValueRegistry()
        XCTAssertFalse(registry.valueExists(name: "amount"))
        registry.registerValue(name: "amount", value: .integer(20))
        XCTAssertTrue(registry.valueExists(name: "amount"))
        XCTAssertEqual(registry.getValue(name: "amount"), .integer(20))
    }
}
