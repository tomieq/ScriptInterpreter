//
//  IoTEngineTests.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class IoTEngineTests: XCTestCase {
    
    func test_sampleCode() {
        
        let console = Console()
        
        let engine = IoTEngine()
        XCTAssertNoThrow(try engine.registerFunc(name: "print", function: console.print))
        XCTAssertNoThrow(try engine.setupVariable(name: "hour", value: .integer(9)))
        XCTAssertNoThrow(try engine.setupVariable(name: "minute", value: .integer(45)))
        
        let code = "if(hour == 9 and minute == 45) { print('right time'); } minute = 12; print(minute); return minute;"
        let returnedValue = try? engine.exec(code: code)
        
        XCTAssertEqual(console.output[safeIndex: 0], .string("right time"))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(12))
        XCTAssertEqual(returnedValue, .integer(12))
    }
    
    func test_returnFromMiddleOfTheCode() {
        
        let engine = IoTEngine()
        let code = "var counter = 0; for(var i = 0; i <= 10; i++) { if(i==5) { return i } } return 100"
        let returnedValue = try? engine.exec(code: code)
        
        XCTAssertEqual(returnedValue, .integer(5))
    }
}

fileprivate class Console {
    var output: [Value] = []
    
    func print(_ vars: [Value]) {
        self.output.append(contentsOf: vars)
    }
}
