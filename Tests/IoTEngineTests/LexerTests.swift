    import XCTest
    @testable import IoTEngine

    final class lexerTests: XCTestCase {

        func test_initWithEmptyCode() {
            XCTAssertNoThrow(try Lexer(code: ""))
        }
        
        func test_basicIfStatement() {
            
            let script = "if (true) { return false }"
            
            do {
                let lexer = try Lexer(code: script)
                XCTAssert(lexer.tokens.count == 8, "Invalid number of tokens")
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_recogniseIntLiteral() {
            let script = "89 == 103"
            do {
                let lexer = try Lexer(code: script)
                XCTAssert(lexer.tokens.count == 3)
                XCTAssertEqual(lexer.tokens[0], .intLiteral(89))
                XCTAssertEqual(lexer.tokens[2], .intLiteral(103))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_recogniseFloatLiteral() {
            let script = "55.13 == 90.7776"
            do {
                let lexer = try Lexer(code: script)
                XCTAssertEqual(lexer.tokens.count, 3, lexer.tokens.debugDescription)
                XCTAssertEqual(lexer.tokens[0], .floatLiteral(55.13))
                XCTAssertEqual(lexer.tokens[2], .floatLiteral(90.7776))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_ifElseStatement() {
            let script = "if(true){ return 89.1 } else { return 100 }"
            do {
                let lexer = try Lexer(code: script)
                let tokens: [Token] = [
                    .ifStatement,
                    .bracketOpen,
                    .boolLiteral(true),
                    .braketClose,
                    .blockOpen,
                    .returnStatement,
                    .floatLiteral(89.1),
                    .blockClose,
                    .elseStatement,
                    .blockOpen,
                    .returnStatement,
                    .intLiteral(100),
                    .blockClose
                ]
                XCTAssertEqual(lexer.tokens.count, tokens.count)
                for (index, token) in tokens.enumerated() {
                    XCTAssertEqual(token, lexer.tokens[index])
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_InvalidFloatNumber() {
            
            let script = " if (unknownToken) { return }"
            
            XCTAssertThrowsError(try Lexer(code: script)){ error in
                XCTAssertNotNil(error as? LexerError)
            }
        }
        
        func test_stringLiteralDoubleQuote() {
            let script = "( \"monkey\" )"
            
            do {
                let lexer = try Lexer(code: script)
                XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey")))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_stringLiteralDoubleQuoteWithSaxon() {
            let script = "( \"monkey's\" )"
            
            do {
                let lexer = try Lexer(code: script)
                XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey's")))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_stringLiteralSingleQuote() {
            let script = "( 'monkey' )"
            
            do {
                let lexer = try Lexer(code: script)
                XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey")))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        func test_functionWithoutArgs() {
            let script = "someAction()"
            
            do {
                let lexer = try Lexer(code: script)
                XCTAssertEqual(lexer.tokens.first, .function(name: "someAction"))
            } catch {
                XCTFail("\(error)")
            }
        }
    }
