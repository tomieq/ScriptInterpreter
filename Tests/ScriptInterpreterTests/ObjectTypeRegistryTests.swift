//
//  ObjectTypeRegistryTests.swift
//  
//
//  Created by Tomasz on 25/03/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter


class ObjectTypeRegistryTests: XCTestCase {
    func test_obtainingNonExistingType() {
        let registry = ObjectTypeRegistry()
        XCTAssertNil(registry.getObjectType("User"))
    }
    
    func test_registerOneType() {
        let registry = ObjectTypeRegistry()
        registry.register(objectType: ObjectType(name: "User", methods: [:]))
        XCTAssertNotNil(registry.getObjectType("User"))
    }
}
