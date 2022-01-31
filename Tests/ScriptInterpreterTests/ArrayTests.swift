//
//  ArrayTests.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class ArrayTests: XCTestCase {
    
    func test_splitByToken() {
        let tokens: [Token] = [.variable(name: "age"), .equal, .intLiteral(38), .semicolon, .function(name: "yell"), .semicolon, .variable(name: "age"), .increment]
        let splitted = tokens.split(by: .semicolon)
        XCTAssertEqual(splitted.count, 3)
        XCTAssertEqual(splitted[safeIndex: 0]?.count, 3)
        XCTAssertEqual(splitted[safeIndex: 1]?.count, 1)
        XCTAssertEqual(splitted[safeIndex: 2]?.count, 2)
    }
}
