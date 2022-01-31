//
//  VariableRegistryTests.swift
//  
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

final class VariableRegistryTests: XCTestCase {

    func test_registerNullVariable() {
        let registry = VariableRegistry()
        XCTAssertFalse(registry.valueExists(name: "amount"))
        XCTAssertNoThrow(try registry.registerValue(name: "amount", value: nil))
        XCTAssertTrue(registry.valueExists(name: "amount"))
    }
    
    func test_registerNonNullVariable() {
        let registry = VariableRegistry()
        XCTAssertFalse(registry.valueExists(name: "amount"))
        XCTAssertNoThrow(try registry.registerValue(name: "amount", value: .integer(20)))
        XCTAssertTrue(registry.valueExists(name: "amount"))
        XCTAssertEqual(registry.getValue(name: "amount"), .integer(20))
    }
    
    func test_reisterVariableInHigherNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        XCTAssertFalse(outer.valueExists(name: "amount"))
        XCTAssertFalse(inner.valueExists(name: "amount"))
        XCTAssertNoThrow(try outer.registerValue(name: "amount", value: .integer(31)))
        XCTAssertTrue(outer.valueExists(name: "amount"))
        XCTAssertTrue(inner.valueExists(name: "amount"))
        
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(31))
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(31))
    }
    
    func test_reisterVariableInLowerNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        XCTAssertFalse(outer.valueExists(name: "amount"))
        XCTAssertFalse(inner.valueExists(name: "amount"))
        XCTAssertNoThrow(try inner.registerValue(name: "amount", value: .integer(31)))
        XCTAssertFalse(outer.valueExists(name: "amount"))
        XCTAssertTrue(inner.valueExists(name: "amount"))
        
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(31))
        XCTAssertNil(outer.getValue(name: "amount"))
    }
    
    func test_reisterVariableInBothNamespaces() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        XCTAssertFalse(outer.valueExists(name: "amount"))
        XCTAssertFalse(inner.valueExists(name: "amount"))
        
        XCTAssertNoThrow(try outer.registerValue(name: "amount", value: .integer(20)))
        XCTAssertNoThrow(try inner.registerValue(name: "amount", value: .integer(100)))
        
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(20))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(100))
    }
    
    func test_updateVariableInHigherNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        
        XCTAssertNoThrow(try outer.registerValue(name: "amount", value: .integer(20)))
        
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(20))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(20))
        
        XCTAssertNoThrow(try outer.updateValue(name: "amount", value: .integer(50)))
        
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(50))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(50))
    }
    
    func test_updateVariableInLowerNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        
        XCTAssertNoThrow(try outer.registerValue(name: "amount", value: .integer(20)))
        
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(20))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(20))
        
        XCTAssertNoThrow(try inner.updateValue(name: "amount", value: .integer(50)))
        
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(50))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(50))
    }
    
    func test_updateConstant() {
        let registry = VariableRegistry()
        
        XCTAssertNoThrow(try registry.registerConstant(name: "amount", value: .integer(20)))
        XCTAssertEqual(registry.getValue(name: "amount"), .integer(20))
        XCTAssertThrowsError(try registry.updateValue(name: "amount", value: .integer(50)))
        
    }
}
