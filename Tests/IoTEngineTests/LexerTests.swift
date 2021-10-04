    import XCTest
    @testable import IoTEngine

    final class lexerTests: XCTestCase {
        func test_initWithEmptyCode() {
            let lexer = Lexer(code: "")
        }
    }
