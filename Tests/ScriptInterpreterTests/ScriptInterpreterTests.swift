//
//  IoTEngineTests.swift
//
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class ScriptInterpreterTests: XCTestCase {
    func test_sampleCode() {
        let console = Console()

        let engine = ScriptInterpreter()
        XCTAssertNoThrow(try engine.registerFunc(name: "print", function: console.print))
        XCTAssertNoThrow(try engine.setupVariable(name: "hour", value: .integer(9)))
        XCTAssertNoThrow(try engine.setupVariable(name: "minute", value: .integer(45)))

        let code = "if(hour == 9 and minute == 45) { print('right time'); } minute = 12; print(minute); return minute;"
        let returnedValue = try? engine.exec(code: code)

        XCTAssertEqual(console.output[safeIndex: 0], .string("right time"))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(12))
        XCTAssertEqual(returnedValue, .integer(12))
    }

    func test_returnFromMiddleOfTheCode() throws {
        let engine = ScriptInterpreter()
        let code = "var counter = 0; for(var i = 0; i <= 10; i++) { if(i==5) { return i } } return 100"
        let returnedValue = try engine.exec(code: code)

        XCTAssertEqual(returnedValue, .integer(5))
    }
    
    func test_switchStatement() throws {
        let code = """
        func getAge(name: String) -> Int {
            switch name {
            case "John":
                return 1
            default:
                return 2
            }
        }
        return getAge("John")
        """
        let engine = ScriptInterpreter()
        let returnedValue = try engine.exec(code: code)
        XCTAssertEqual(returnedValue, .integer(1))
    }
    
    func test_classWithoutInit() throws {
        let code = """
        class Car {
            let licencePlate = "EL6238"
        init() {}
        }
        let car = Car()
        return car.licencePlate
        """
        let engine = ScriptInterpreter()
        let returnedValue = try engine.exec(code: code)
        XCTAssertEqual(returnedValue, .string("EL6238"))
    }

    func test_classWithExplicitInit() throws {
        let code = """
        class Car {
            var licence: String
            init(_ licence: String) {
                self.licence = licence
            }
        }
        func test(who: String) {
            who = "po"
        }
        test("one")
        let car = Car("EL6238")
        return car.licence
        """
        let engine = ScriptInterpreter()
        let returnedValue = try? engine.exec(code: code)
        XCTAssertEqual(returnedValue, .string("EL6238"))
    }
}

fileprivate class Console {
    var output: [Value] = []

    func print(_ vars: [Value]) {
        self.output.append(contentsOf: vars)
    }
}
