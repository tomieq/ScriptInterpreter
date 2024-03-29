import XCTest
@testable import ScriptInterpreter

final class LexerTests: XCTestCase {
    func test_initWithEmptyCode() {
        XCTAssertNoThrow(try Lexer(code: ""))
    }

    func test_basicIfStatement() {
        let script = "if (true) { return false }"

        do {
            let lexer = try Lexer(code: script)
            XCTAssert(lexer.tokens.count == 8, "Invalid number of tokens")
        } catch {
            XCTFail("\(error)")
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
            XCTFail("\(error)")
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
            XCTFail("\(error)")
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
                .bracketClose,
                .blockOpen,
                .return,
                .floatLiteral(89.1),
                .blockClose,
                .elseStatement,
                .blockOpen,
                .return,
                .intLiteral(100),
                .blockClose,
            ]
            XCTAssertEqual(lexer.tokens.count, tokens.count)
            for (index, token) in tokens.enumerated() {
                XCTAssertEqual(token, lexer.tokens[index])
            }
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_variable() {
        let script = " if (someVar) { return }"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .variable(name: "someVar"))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_stringLiteralDoubleQuote() {
        let script = "( \"monkey\" )"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey")))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_stringLiteralDoubleQuoteWithSaxon() {
        let script = "( \"monkey's\" )"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey's")))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_stringLiteralDoubleQuoteWithInterpolatedVariable() {
        let script = "( \"monkey eats\\(variable)\" )"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey eats\\(variable)")))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_stringLiteralSingleQuote() {
        let script = "( 'monkey' )"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey")))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_stringLiteralSingleQuoteWithInterpolatedVariable() {
        let script = "( 'monkey eats \\(banana)' )"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertTrue(lexer.tokens.contains(.stringLiteral("monkey eats \\(banana)")))
        } catch {
            XCTFail("\(error)")
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

    func test_functionWithOneArgument() {
        let script = "drive(false)"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens.first, .functionWithArguments(name: "drive"))
            XCTAssertEqual(lexer.tokens[1], .bracketOpen)
            XCTAssertEqual(lexer.tokens[2], .boolLiteral(false))
            XCTAssertEqual(lexer.tokens[3], .bracketClose)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_functionWithTwoArguments() {
        let script = "run(\"left\", 12)"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens.first, .functionWithArguments(name: "run"))
            XCTAssertEqual(lexer.tokens[2], .stringLiteral("left"))
            XCTAssertEqual(lexer.tokens[3], .comma)
            XCTAssertEqual(lexer.tokens[4], .intLiteral(12))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_andOperatorWithSpaces() {
        let script = "if(true && false){}"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[2], .boolLiteral(true))
            XCTAssertEqual(lexer.tokens[3], .andOperator)
            XCTAssertEqual(lexer.tokens[4], .boolLiteral(false))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_andOperatorWithoutSpaces() {
        let script = "if(true&&false){}"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[2], .boolLiteral(true))
            XCTAssertEqual(lexer.tokens[3], .andOperator)
            XCTAssertEqual(lexer.tokens[4], .boolLiteral(false))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_orOperatorWithSpaces() {
        let script = "if(true || false){}"

        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[2], .boolLiteral(true))
            XCTAssertEqual(lexer.tokens[3], .orOperator)
            XCTAssertEqual(lexer.tokens[4], .boolLiteral(false))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_recogniseSemicolon() {
        let script = "execute();"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .function(name: "execute"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .semicolon)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_variableDefinition() {
        let script = "var lenght = 380.5"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .variableDefinition(type: "var"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .variable(name: "lenght"))
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .assign)
            XCTAssertEqual(lexer.tokens[safeIndex: 3], .floatLiteral(380.5))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_constantVariableDefinition() {
        let script = "let age = 34"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .constantDefinition(type: "let"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .variable(name: "age"))
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .assign)
            XCTAssertEqual(lexer.tokens[safeIndex: 3], .intLiteral(34))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_functionDefinition() {
        let script = "function exec() { print(\"error\") }"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .functionDefinition(type: "function"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .function(name: "exec"))
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .blockOpen)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_functionDefinitionWithArguments() {
        let script = "func exec(counter) { print(counter) }"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .functionDefinition(type: "func"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .functionWithArguments(name: "exec"))
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .bracketOpen)
            XCTAssertEqual(lexer.tokens[safeIndex: 3], .variable(name: "counter"))
            XCTAssertEqual(lexer.tokens[safeIndex: 4], .bracketClose)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func test_functionDefinitionWithExplicitReturnType() {
        let script = "function exec() -> Int { print(\"error\") }"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .functionDefinition(type: "function"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .function(name: "exec"))
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .swiftReturnSign)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_conditionCheckWithNotEqual() {
        let script = "72 != 10"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .intLiteral(72))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .notEqual)
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .intLiteral(10))
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_classDefinition() {
        let script = "class User{}"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .class(name: "User"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .blockOpen)
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .blockClose)
        } catch {
            XCTFail("\(error)")
        }
    }

    func test_classDefinitionWithExplicitInit() {
        let script = "class User { init() { 12} }"
        do {
            let lexer = try Lexer(code: script)
            XCTAssertEqual(lexer.tokens[safeIndex: 0], .class(name: "User"))
            XCTAssertEqual(lexer.tokens[safeIndex: 1], .blockOpen)
            XCTAssertEqual(lexer.tokens[safeIndex: 2], .functionDefinition(type: "init"))
            XCTAssertEqual(lexer.tokens[safeIndex: 3], .function(name: "init"))
            XCTAssertEqual(lexer.tokens[safeIndex: 4], .blockOpen)
        } catch {
            XCTFail("\(error)")
        }
    }
}
