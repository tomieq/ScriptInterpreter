//
//  BlockParserTests.swift
//  
//
//  Created by Tomasz Kucharski on 29/01/2022.
//

import Foundation
import XCTest
@testable import IoTEngine


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
}
