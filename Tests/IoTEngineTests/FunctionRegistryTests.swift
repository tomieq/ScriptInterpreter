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
        sut.registerFunc(name: "spy", function: spy.spyFunction)
        
        XCTAssertEqual(spy.callCounter, 0)
        sut.callFunction(name: "spy")
        XCTAssertEqual(spy.callCounter, 1)
    }
    

}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    
    func spyFunction() {
        self.callCounter += 1
    }
}
