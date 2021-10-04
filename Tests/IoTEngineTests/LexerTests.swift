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
                XCTAssert(lexer.tokens.count == 3)
                XCTAssertEqual(lexer.tokens[0], .floatLiteral(55.13))
                XCTAssertEqual(lexer.tokens[2], .floatLiteral(90.7776))
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
