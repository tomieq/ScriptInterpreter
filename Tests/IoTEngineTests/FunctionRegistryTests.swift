//
//  FunctionRegistryTests.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine

class FunctionRegistryTests: XCTestCase {

    func test_registeringFunction() {
        let spy = FunctionCallSpy()
        
        let sut = FunctionRegistry()
        XCTAssertNoThrow(try sut.registerFunc(name: "spy", function: spy.spyFunction))
        
        XCTAssertEqual(spy.callCounter, 0)
        sut.callFunction(name: "spy")
        XCTAssertEqual(spy.callCounter, 1)

    }
    
    func test_registeringFunctionWithStringArgument() {
        let spy = FunctionCallSpy()
        
        let sut = FunctionRegistry()
        XCTAssertNoThrow(try sut.registerFunc(name: "receive", function: spy.receive))
        
        XCTAssertEqual(spy.received.count, 0)
        sut.callFunction(name: "receive", args: [.string("lego")])
        XCTAssertEqual(spy.received.count, 1)
    }

    func test_registeringTheSameNameFunction() {
        let spy = FunctionCallSpy()
        
        let sut = FunctionRegistry()
        XCTAssertNoThrow(try sut.registerFunc(name: "spy", function: spy.spyFunction))
        XCTAssertThrowsError(try sut.registerFunc(name: "spy", function: spy.spyFunction))
    }

    func test_registeringTheSameNameFunctionWithArgs() {
        let spy = FunctionCallSpy()
        
        let sut = FunctionRegistry()
        XCTAssertNoThrow(try sut.registerFunc(name: "receive", function: spy.receive))
        XCTAssertThrowsError(try sut.registerFunc(name: "receive", function: spy.receive))
    }
}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    var received: [Value] = []
    
    func spyFunction() {
        self.callCounter += 1
    }
    
    func receive(values: [Value]) {
        self.received.append(contentsOf: values)
    }
}
