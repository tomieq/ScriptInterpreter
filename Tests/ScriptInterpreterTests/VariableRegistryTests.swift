//
//  VariableRegistryTests.swift
//
//
//  Created by Tomasz Kucharski on 28/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

fileprivate extension VariableRegistry {
    func registerVariable(name: String, value: Value) throws {
        try self.registerVariable(name: name, variable: .primitive(value))
    }

    func getValue(name: String) -> Value? {
        guard let variable = self.getVariable(name: name) else { return nil }
        switch variable {
        case .primitive(let value):
            return value
        case .class(_, _):
            return nil
        }
    }
}

final class VariableRegistryTests: XCTestCase {
    func test_registerNullVariable() {
        let registry = VariableRegistry()
        XCTAssertFalse(registry.variableExists(name: "amount"))
        XCTAssertNoThrow(try registry.registerVariable(name: "amount", variable: nil))
        XCTAssertTrue(registry.variableExists(name: "amount"))
    }

    func test_registerNonNullVariable() {
        let registry = VariableRegistry()
        XCTAssertFalse(registry.variableExists(name: "amount"))
        XCTAssertNoThrow(try registry.registerVariable(name: "amount", value: .integer(20)))
        XCTAssertTrue(registry.variableExists(name: "amount"))
        XCTAssertEqual(registry.getValue(name: "amount"), .integer(20))
    }

    func test_reisterVariableInHigherNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        XCTAssertFalse(outer.variableExists(name: "amount"))
        XCTAssertFalse(inner.variableExists(name: "amount"))
        XCTAssertNoThrow(try outer.registerVariable(name: "amount", value: .integer(31)))
        XCTAssertTrue(outer.variableExists(name: "amount"))
        XCTAssertTrue(inner.variableExists(name: "amount"))

        XCTAssertEqual(inner.getValue(name: "amount"), .integer(31))
        XCTAssertEqual(outer.getValue(name: "amount"), .integer(31))
    }

    func test_reisterVariableInLowerNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        XCTAssertFalse(outer.variableExists(name: "amount"))
        XCTAssertFalse(inner.variableExists(name: "amount"))
        XCTAssertNoThrow(try inner.registerVariable(name: "amount", value: .integer(31)))
        XCTAssertFalse(outer.variableExists(name: "amount"))
        XCTAssertTrue(inner.variableExists(name: "amount"))

        XCTAssertEqual(inner.getValue(name: "amount"), .integer(31))
        XCTAssertNil(outer.getValue(name: "amount"))
    }

    func test_reisterVariableInBothNamespaces() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)
        XCTAssertFalse(outer.variableExists(name: "amount"))
        XCTAssertFalse(inner.variableExists(name: "amount"))

        XCTAssertNoThrow(try outer.registerVariable(name: "amount", value: .integer(20)))
        XCTAssertNoThrow(try inner.registerVariable(name: "amount", value: .integer(100)))

        XCTAssertEqual(outer.getValue(name: "amount"), .integer(20))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(100))
    }

    func test_updateVariableInHigherNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)

        XCTAssertNoThrow(try outer.registerVariable(name: "amount", value: .integer(20)))

        XCTAssertEqual(outer.getValue(name: "amount"), .integer(20))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(20))

        XCTAssertNoThrow(try outer.updateVariable(name: "amount", variable: .primitive(.integer(50))))

        XCTAssertEqual(outer.getValue(name: "amount"), .integer(50))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(50))
    }

    func test_updateVariableInLowerNamespace() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)

        XCTAssertNoThrow(try outer.registerVariable(name: "amount", value: .integer(20)))

        XCTAssertEqual(outer.getValue(name: "amount"), .integer(20))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(20))

        XCTAssertNoThrow(try inner.updateVariable(name: "amount", variable: .primitive(.integer(50))))

        XCTAssertEqual(outer.getValue(name: "amount"), .integer(50))
        XCTAssertEqual(inner.getValue(name: "amount"), .integer(50))
    }

    func test_updateConstant() {
        let registry = VariableRegistry()

        XCTAssertNoThrow(try registry.registerConstant(name: "amount", variable: .primitive(.integer(20))))
        XCTAssertEqual(registry.getValue(name: "amount"), .integer(20))
        XCTAssertThrowsError(try registry.updateVariable(name: "amount", variable: .primitive(.integer(50))))
    }

    func test_memoryDump() {
        let outer = VariableRegistry()
        let inner = VariableRegistry(topVariableRegistry: outer)

        XCTAssertNoThrow(try outer.registerVariable(name: "amount", value: .integer(20)))

        XCTAssertEqual(outer.memoryDump()["amount"], .integer(20))
        XCTAssertEqual(inner.memoryDump()["amount"], .integer(20))
    }

    func test_clearMemory() {
        let registry = VariableRegistry()

        XCTAssertNoThrow(try registry.registerVariable(name: "amount", value: .integer(20)))
        XCTAssertEqual(registry.getValue(name: "amount"), .integer(20))
        registry.clearMemory()
        XCTAssertNil(registry.getValue(name: "amount"))
    }
}
