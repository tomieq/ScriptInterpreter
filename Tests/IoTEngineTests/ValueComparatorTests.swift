//
//  ValueComparatorTests.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class ValueComparatorTests: XCTestCase {
    
    func testCompareIntegers() {
        let variableRegister = ValueRegistry()
        variableRegister.registerValue(name: "current", value: .integer(25))
        
        XCTAssertEqual(self.check(.intLiteral(10), .intLiteral(23), variableRegister), .rightGreater)
        XCTAssertEqual(self.check(.intLiteral(33), .intLiteral(33), variableRegister), .equal)
        XCTAssertEqual(self.check(.intLiteral(100), .intLiteral(99), variableRegister), .leftGreater)
        
        XCTAssertEqual(self.check(.variable(name: "current"), .intLiteral(25), variableRegister), .equal)
        XCTAssertEqual(self.check(.variable(name: "current"), .intLiteral(2), variableRegister), .leftGreater)
        XCTAssertEqual(self.check(.variable(name: "current"), .intLiteral(500), variableRegister), .rightGreater)
        
        
        XCTAssertEqual(self.check(.intLiteral(25), .variable(name: "current"), variableRegister), .equal)
        XCTAssertEqual(self.check(.intLiteral(-3), .variable(name: "current"), variableRegister), .rightGreater)
        XCTAssertEqual(self.check(.intLiteral(88), .variable(name: "current"), variableRegister), .leftGreater)
    }
    
    private func check(_ left: Token, _ right: Token, _ variableRegister: ValueRegistry) -> ValueComparatorResult? {
        do {
            let comparator = ValueComparator()
            return try comparator.compare(left: left, right: right, variableRegister: variableRegister)
        } catch {
            XCTFail(error.localizedDescription)
        }
        return nil
    }
}
