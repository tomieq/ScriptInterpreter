//
//  ParserObjectTests.swift
//
//
//  Created by Tomasz on 25/03/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class ParserObjectTests: XCTestCase {
    func test_initilizingClass() throws {
        let spy = self.setupSpy(code: "class User { init() { print('initialized') } } let user = User()")
        XCTAssertEqual(spy.output, [.string("initialized")])
    }

    func test_initilizingClassWithArguments() throws {
        let code = """
        class Computer {
            init(_ label: String) {
                print(label)
            }
        }
        let computer = Computer("Office")
        """
        let spy = self.setupSpy(code: code)
        XCTAssertEqual(spy.output, [.string("Office")])
    }

    func test_callMethodOnClassInstance() throws {
        let spy = self.setupSpy(code: "class User { func execute() { print('done') } } let user = User(); user.execute()")
        XCTAssertEqual(spy.output, [.string("done")])
    }

    func test_callMultipleMethodsOnClassInstance() throws {
        let code = """
        class Computer {
            init() {
                print('started')
            }
            func switchOn() {
                print('working')
            }
            func turnOff() {
                print('finished')
            }
        }
        let computer = Computer()
        computer.switchOn()
        computer.turnOff()
        """
        let spy = self.setupSpy(code: code)
        XCTAssertEqual(spy.output, [.string("started"), .string("working"), .string("finished")])
    }

    func test_callMethodOnClassInstanceWithArguments() throws {
        let code = """
        class Computer {
            init(_ owner: String) {
                print(owner)
            }
            func connectTo(ip: String) {
                print(ip)
            }
        }
        let computer = Computer("Thomas")
        computer.connectTo("127.0.0.1")
        """
        let spy = self.setupSpy(code: code)
        XCTAssertEqual(spy.output, [.string("Thomas"), .string("127.0.0.1")])
    }

    func test_initilizerLocalVariables() throws {
        let code = """

        class Computer {
            var age = 37
            init(newAge) {
                print(age)
                age = newAge
                print(age)
            }
            func run(newAge) {
                age = newAge
                print(age)
            }
        }
        let computer = Computer(12)
        computer.run(100)
        let computer2 = Computer(10)
        computer2.run(3)
        """
        let spy = self.setupSpy(code: code)
        XCTAssertEqual(spy.output, [
            .integer(37), .integer(12), .integer(100),
            .integer(37), .integer(10), .integer(3)])
    }

    func test_selfUsage() throws {
        let code = """

        class Computer {
            var age = 100
            init(newAge) {
                print(self.age)
                self.age = newAge
                print(self.age)
            }
            func run(newAge) {
                self.age = newAge
                print(self.age)
            }
        }
        let computer = Computer(200)
        computer.run(300)
        """
        let spy = self.setupSpy(code: code)
        XCTAssertEqual(spy.output, [.integer(100), .integer(200), .integer(300)])
    }

    func test_globalFunctionUsage() throws {
        let code = """
        func global(val) {
            print(val)
        }

        class Computer {
            var age = 100
            init() {
                global(self.age)
            }
            func run(newAge) {
                global(newAge)
            }
        }
        let computer = Computer()
        computer.run(300)
        """
        let spy = self.setupSpy(code: code)
        XCTAssertEqual(spy.output, [.integer(100), .integer(300)])
    }

    private func setupSpy(code: String) -> FunctionCallSpy {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, externalFunctionRegistry: functionRegistry)
            XCTAssertNoThrow(try parser.execute())
        } catch {
            XCTFail(error.localizedDescription)
        }
        return spy
    }
}

fileprivate class FunctionCallSpy {
    var output: [Value] = []

    func print(_ data: [Value]) {
        self.output.append(contentsOf: data)
    }
}
