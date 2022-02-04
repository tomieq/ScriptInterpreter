//
//  ParserTests.swift
//
//  Created by Tomasz Kucharski on 04/10/2021.
//

import XCTest
@testable import ScriptInterpreter

class ParserTests: XCTestCase {

    func test_callingExternalFunctionWithoutArgs() throws {
        
        let spy = self.setupSpy(code: "increaseCounter()")
        XCTAssertEqual(spy.callCounter, 1)
    }
    
    func test_callingTwoExternalFunctions() throws {
        
        let spy = self.setupSpy(code: "increaseCounter() addTwo()")
        XCTAssertEqual(spy.callCounter, 3)
    }
    
    func test_callExternalFunctionWithArguments() {
        let spy = self.setupSpy(code: "print(true, 20, 'works', 3.14)")
        XCTAssertEqual(spy.output.count, 4)
        XCTAssertEqual(spy.output[safeIndex: 0], .bool(true))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(20))
        XCTAssertEqual(spy.output[safeIndex: 2], .string("works"))
        XCTAssertEqual(spy.output[safeIndex: 3], .float(3.14))
    }
    
    func test_callExternalFunctionWithVariableValue() {
        let spy = self.setupSpy(code: "var number = 55; print(number);")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(55))
    }
    
    func test_ifElseStatementTrue() {
        let spy = self.setupSpy(code: "var execute = true; if(execute) { print(20) } else { print(21); }")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(20))
    }
    
    func test_ifElseStatementFalse() {
        let spy = self.setupSpy(code: "var execute = false; if(execute) { print(20) } else { print(21, 22); }")
        XCTAssertEqual(spy.output.count, 2)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(21))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(22))
    }
    
    func test_variableNamespaceIfStatement() {
        let spy = self.setupSpy(code: "var execute = true; var amount = 5 ; if(execute) { print(amount) } else { print(21); }")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(5))
    }
    
    func test_variableNamespaceElseStatement() {
        let spy = self.setupSpy(code: "var execute = false; var amount = 5 ; if(execute) { print(50) } else { print(amount); }")
        XCTAssertEqual(spy.output.count, 1)
        XCTAssertEqual(spy.output[safeIndex: 0], .integer(5))
    }
    
    func test_variableLocalNamespace() {
        let spy = self.setupSpy(code: "var execute = true; var amount = 5 ; if(execute) { let amount = false; print(amount) } print(amount);")
        XCTAssertEqual(spy.output.count, 2)
        XCTAssertEqual(spy.output[safeIndex: 0], .bool(false))
        XCTAssertEqual(spy.output[safeIndex: 1], .integer(5))
    }
    
    func test_sampleProgram() {
        let spy = self.setupSpy(code: "print(\"hello\"); print(\"world\"); var counter = 9; if ( counter == 9 ) { print('ok') } else { print('wrong') }")
        XCTAssertEqual(spy.output.count, 3)
        XCTAssertEqual(spy.output[safeIndex: 0], .string("hello"))
        XCTAssertEqual(spy.output[safeIndex: 1], .string("world"))
        XCTAssertEqual(spy.output[safeIndex: 2], .string("ok"))
        
        
        let console = self.setupSpy(code: "var counter = 12; if ( counter == 9 ) { print('the same') } else { print('different') }")
        XCTAssertEqual(console.output.count, 1)
        XCTAssertEqual(console.output[safeIndex: 0], .string("different"))
    }
    
    func test_assignVariable() {
        let console = self.setupSpy(code: "var age = 40; print(age); age = 50; print(age);")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(40))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(50))
        
        
        let console2 = self.setupSpy(code: "var min = 10; var max = 100; var current = 50; print(current); current = min; print(current);")
        XCTAssertEqual(console2.output.count, 2)
        XCTAssertEqual(console2.output[safeIndex: 0], .integer(50))
        XCTAssertEqual(console2.output[safeIndex: 1], .integer(10))
    }
    
    func test_variableIncrement() {
        let console = self.setupSpy(code: "var distance = 9; print(distance); distance++; print(distance)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(9))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(10))
    }
    
    func test_variableDecrement() {
        let console = self.setupSpy(code: "var distance = 9; print(distance); distance--; print(distance)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(9))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(8))
    }
    
    func test_whileLoop() {
        let console = self.setupSpy(code: "var i = 0; while(i < 5) { i++; print(i) }")
        XCTAssertEqual(console.output.count, 5)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 4], .integer(5))
    }
    
    func test_breakWhileLoop() {
        let console = self.setupSpy(code: "var i = 0; while(i <= 5) { i++; print(i) if(i==2){ break } } print(3.14)")
        XCTAssertEqual(console.output.count, 3)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(2))
        XCTAssertEqual(console.output[safeIndex: 2], .float(3.14))
    }
    
    func test_returnWhileLoop() {
        let console = self.setupSpy(code: "var i = 0; while(i <= 5) { i++; print(i) if(i==2){ return } }  print(3.14)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(2))
    }

    func test_forLoop() {
        let console = self.setupSpy(code: "var i = 9; for(var i = 1; i <= 5; i++) { print(i) } print(i)")
        XCTAssertEqual(console.output.count, 6)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 4], .integer(5))
        XCTAssertEqual(console.output[safeIndex: 5], .integer(9))
    }
    
    func test_breakInForLoop() {
        let console = self.setupSpy(code: "for(var i = 1; i <= 5; i++) { print(i) if(i==2){break} } print(10)")
        XCTAssertEqual(console.output.count, 3)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(2))
        XCTAssertEqual(console.output[safeIndex: 2], .integer(10))
    }
    
    func test_returnFromForLoop() {
        let console = self.setupSpy(code: "for(var i = 1; i <= 5; i++) { print(i) if(i==2){return} } print(10)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(2))
    }

    func test_namespaceVariables() {
        let console = self.setupSpy(code: "var number = 0; print(number) { var number = 6; print(number) number--; print(number) } number++; print(number)")
        XCTAssertEqual(console.output.count, 4)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(0))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(6))
        XCTAssertEqual(console.output[safeIndex: 2], .integer(5))
        XCTAssertEqual(console.output[safeIndex: 3], .integer(1))
    }
    
    func test_updateConstant() {
        self.expectError(code: "let pi = 3.14; pi = 5.5")
    }
    
    func test_callThrowingFunction() {
        self.expectError(code: "let pi = 3.14; error()")
    }
    
    func test_returnLiteralValue() {
        do {
            let lexer = try Lexer(code: "return 32")
            let parser = Parser(tokens: lexer.tokens)
            let result = try parser.execute()
            XCTAssertEqual(result, .return(.integer(32)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_returnedValueInterpolation() {
        do {
            let lexer = try Lexer(code: "let distance = 89; var speed = 51; speed = 38; return 'Car travelled \\(distance) with \\(speed) speed'")
            let parser = Parser(tokens: lexer.tokens)
            let result = try parser.execute()
            XCTAssertEqual(result, .return(.string("Car travelled 89 with 38 speed")))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_returnVariable() {
        do {
            let lexer = try Lexer(code: "let pi = 3.14; return pi")
            let parser = Parser(tokens: lexer.tokens)
            let result = try parser.execute()
            XCTAssertEqual(result, .return(.float(3.14)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_returnLiteral() {
        do {
            let lexer = try Lexer(code: "return 8")
            let parser = Parser(tokens: lexer.tokens)
            let result = try parser.execute()
            XCTAssertEqual(result, .return(.integer(8)))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_usingVariableNamesBeginningWithKeywordName() {
        let console = self.setupSpy(code: "var ifer = 3; var breaker = 10; var elser = 20; var whiler = 9 print(ifer, breaker, elser)")
        XCTAssertEqual(console.output[safeIndex: 0], .integer(3))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(10))
        XCTAssertEqual(console.output[safeIndex: 2], .integer(20))
    }
    
    func test_defineFunctionWithoutArguments() {
        let console = self.setupSpy(code: "var number = 0; func welcome(){ var number = 5; print(5) } welcome() print(number)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(5))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(0))
    }
    
    func test_defineFunctionWitArguments() {
        let console = self.setupSpy(code: "var number = 0; func dump(a, b){ var number = 3; print(a, b, number) } dump(1, 2) print(number)")
        XCTAssertEqual(console.output.count, 4)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(1))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(2))
        XCTAssertEqual(console.output[safeIndex: 2], .integer(3))
        XCTAssertEqual(console.output[safeIndex: 3], .integer(0))
    }
    
    func test_updateGlobalVariableInFunction() {
        let console = self.setupSpy(code: "var number = 0; func updateNumber(newVal){ number = newVal; } updateNumber(8) print(number)")
        XCTAssertEqual(console.output.count, 1)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(8))
    }
    
    func test_assignFunctionReturnValueToVariable() {
        let console = self.setupSpy(code: "var distance = 4 func getValue(){ return 8 }  distance = getValue() print(distance)")
        XCTAssertEqual(console.output.count, 1)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(8))
    }
    
    func test_executionAbort() {
        do {
            let spy = FunctionCallSpy()
            let functionRegistry = ExternalFunctionRegistry()
            XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
            let lexer = try Lexer(code: "var counter = 0; while(true){ counter++ print(counter)}")
            let parser = Parser(tokens: lexer.tokens, externalFunctionRegistry: functionRegistry)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.005) {
                parser.abort(reason: "Execution timeout")
            }
            XCTAssertThrowsError(try parser.execute())
            XCTAssertTrue(spy.output.count > 0)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func test_switchStatementSomeCase() {
        let console = self.setupSpy(code: "var number = 10; switch number { case 3: print(3) case 10: print(10) default: print(33) } print(21)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(10))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(21))
    }
    
    func test_switchStatementDefault() {
        let console = self.setupSpy(code: "var number = 10; switch number { case 3: print(3) case 11: print(10) default: print(33) } print(21)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(33))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(21))
    }
    
    func test_switchStatementControlVariableAsFunctionWithoutArguments() {
        let console = self.setupSpy(code: "func control() { return 3 } switch control() { case 3: print(3) case 11: print(10) default: print(33) } print(21)")
        XCTAssertEqual(console.output.count, 2)
        XCTAssertEqual(console.output[safeIndex: 0], .integer(3))
        XCTAssertEqual(console.output[safeIndex: 1], .integer(21))
    }
    
    private func setupSpy(code: String) -> FunctionCallSpy {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseCounter))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.addTwo))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "error", function: spy.error))
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, externalFunctionRegistry: functionRegistry)
            XCTAssertNoThrow(try parser.execute())
        } catch {
            XCTFail(error.localizedDescription)
        }
        return spy
    }
    
    private func expectError(code: String) {
        let spy = FunctionCallSpy()
        let functionRegistry = ExternalFunctionRegistry()
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "print", function: spy.print))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "increaseCounter", function: spy.increaseCounter))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "addTwo", function: spy.addTwo))
        XCTAssertNoThrow(try functionRegistry.registerFunc(name: "error", function: spy.error))
        do {
            let lexer = try Lexer(code: code)
            let parser = Parser(tokens: lexer.tokens, externalFunctionRegistry: functionRegistry)
            XCTAssertThrowsError(try parser.execute())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

fileprivate class FunctionCallSpy {
    var callCounter = 0
    var output: [Value] = []
    
    func increaseCounter() {
        self.callCounter += 1
    }
    
    func addTwo() {
        self.callCounter += 2
    }
    
    func print(_ data: [Value]) {
        self.output.append(contentsOf: data)
    }
    
    func error() throws {
        throw ParserError.syntaxError(description: "TestError")
    }
}
