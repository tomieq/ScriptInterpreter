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
