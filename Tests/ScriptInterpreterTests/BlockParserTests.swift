//
//  BlockParserTests.swift
//
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class BlockParserTests: XCTestCase {
    func test_tokenAmount() {
        let code = "var size = 8; if(true) { size = 4; } else { size = 2 }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getIfBlock(ifTokenIndex: 5)
            XCTAssertEqual(result.conditionTokens.count, 1)
            XCTAssertEqual(result.mainTokens.count, 4)
            XCTAssertEqual(result.elseTokens?.count, 3)
            XCTAssertEqual(result.consumedTokens, 16)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_ifStatement() {
        let code = "var size = 18; if(size == 18) { size = 4; }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getIfBlock(ifTokenIndex: 5)
            XCTAssertEqual(result.conditionTokens.count, 3)
            XCTAssertEqual(result.conditionTokens[safeIndex: 0], .variable(name: "size"))
            XCTAssertEqual(result.conditionTokens[safeIndex: 1], .equal)
            XCTAssertEqual(result.conditionTokens[safeIndex: 2], .intLiteral(18))
            XCTAssertEqual(result.mainTokens.count, 4)
            XCTAssertEqual(result.mainTokens[safeIndex: 0], .variable(name: "size"))
            XCTAssertEqual(result.mainTokens[safeIndex: 1], .assign)
            XCTAssertEqual(result.mainTokens[safeIndex: 2], .intLiteral(4))
            XCTAssertNil(result.elseTokens)
            XCTAssertEqual(result.consumedTokens, 12)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_ifElseStatement() {
        let code = "print('Starting'); if(hour == 14 && minute == 00) { runMotor(); } else { stopMotor(); }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getIfBlock(ifTokenIndex: 5)
            XCTAssertEqual(result.conditionTokens.count, 7)
            XCTAssertEqual(result.conditionTokens[safeIndex: 0], .variable(name: "hour"))
            XCTAssertEqual(result.conditionTokens[safeIndex: 1], .equal)
            XCTAssertEqual(result.conditionTokens[safeIndex: 2], .intLiteral(14))
            XCTAssertEqual(result.conditionTokens[safeIndex: 3], .andOperator)
            XCTAssertEqual(result.conditionTokens[safeIndex: 4], .variable(name: "minute"))
            XCTAssertEqual(result.conditionTokens[safeIndex: 5], .equal)
            XCTAssertEqual(result.conditionTokens[safeIndex: 6], .intLiteral(0))
            XCTAssertEqual(result.mainTokens.count, 2)
            XCTAssertEqual(result.mainTokens[safeIndex: 0], .function(name: "runMotor"))
            XCTAssertEqual(result.mainTokens[safeIndex: 1], .semicolon)
            XCTAssertEqual(result.elseTokens?.count, 2)
            XCTAssertEqual(result.elseTokens?[safeIndex: 0], .function(name: "stopMotor"))
            XCTAssertEqual(result.elseTokens?[safeIndex: 1], .semicolon)
            XCTAssertEqual(result.consumedTokens, 19)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_whileStatement() {
        let code = "var i = 0; while(i < 5) { i++ }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getWhileBlock(whileTokenIndex: 5)
            XCTAssertEqual(result.conditionTokens.count, 3)
            XCTAssertEqual(result.conditionTokens[safeIndex: 0], .variable(name: "i"))
            XCTAssertEqual(result.conditionTokens[safeIndex: 1], .less)
            XCTAssertEqual(result.conditionTokens[safeIndex: 2], .intLiteral(5))
            XCTAssertEqual(result.mainTokens.count, 2)
            XCTAssertEqual(result.mainTokens[safeIndex: 0], .variable(name: "i"))
            XCTAssertEqual(result.mainTokens[safeIndex: 1], .increment)
            XCTAssertNil(result.elseTokens)
            XCTAssertEqual(result.consumedTokens, 10)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_forStatement() {
        let code = "var i = 0; for(var i = 0; i < 5; i++) { ; }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getForBlock(forTokenIndex: 5)
            XCTAssertEqual(result.initialState[safeIndex: 0], .variableDefinition(type: "var"))
            XCTAssertEqual(result.initialState[safeIndex: 1], .variable(name: "i"))
            XCTAssertEqual(result.initialState[safeIndex: 2], .assign)
            XCTAssertEqual(result.initialState[safeIndex: 3], .intLiteral(0))

            XCTAssertEqual(result.condition[safeIndex: 0], .variable(name: "i"))
            XCTAssertEqual(result.condition[safeIndex: 1], .less)
            XCTAssertEqual(result.condition[safeIndex: 2], .intLiteral(5))

            XCTAssertEqual(result.finalExpression[safeIndex: 0], .variable(name: "i"))
            XCTAssertEqual(result.finalExpression[safeIndex: 1], .increment)

            XCTAssertEqual(result.body.count, 1)
            XCTAssertEqual(result.body[safeIndex: 0], .semicolon)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_switchSwiftStyle() {
        let code = "switch name { case 'Ryan': break; default: b++ case 'Dwigth': break; }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getSwitchBlock(switchTokenIndex: 0)
            XCTAssertEqual(result.variable, .variable(name: "name"))

            XCTAssertEqual(result.cases[.stringLiteral("Ryan")], [.break, .semicolon])
            XCTAssertEqual(result.cases[.stringLiteral("Dwigth")], [.break, .semicolon])

            XCTAssertEqual(result.default[safeIndex: 0], .variable(name: "b"))
            XCTAssertEqual(result.default[safeIndex: 1], .increment)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_switchJavaScriptStyle() {
        let code = "switch (name) { case 'Ryan': break; case 'Dwigth': break; default: a++ }"
        do {
            let lexer = try Lexer(code: code)
            let parser = BlockParser(tokens: lexer.tokens)
            let result = try parser.getSwitchBlock(switchTokenIndex: 0)
            XCTAssertEqual(result.variable, .variable(name: "name"))

            XCTAssertEqual(result.default[safeIndex: 0], .variable(name: "a"))
            XCTAssertEqual(result.default[safeIndex: 1], .increment)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
