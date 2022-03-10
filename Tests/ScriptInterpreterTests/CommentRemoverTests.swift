//
//  CommentRemoverTests.swift
//
//
//  Created by Tomasz Kucharski on 04/02/2022.
//

import Foundation
import XCTest
@testable import ScriptInterpreter

class CommentRemoverTests: XCTestCase {
    func test_removingMultilineComment() {
        let script = """
        /****
         * Common multi-line comment style.
         ****/text
        """
        let remover = CommentRemover(script: script)
        let text = remover.cleaned
        XCTAssertEqual(text.condenseWhitespace(), "text")
    }

    func test_removingMultipleMultilineComment() {
        let script = """
        /****
         * Common multi-line comment style.
         ****/one/*
            some comment that should be cut out! (tips)
        */
        two
        """
        let remover = CommentRemover(script: script)
        let text = remover.cleaned
        XCTAssertEqual(text.condenseWhitespace(), "one two")
    }

    func test_removingOneLineComment() {
        let script = """
        // this is one line comment
        code here
        // here is second comment
        dalej
        """
        let remover = CommentRemover(script: script)
        let text = remover.cleaned
        XCTAssertEqual(text.condenseWhitespace(), "code here dalej")
    }
}

fileprivate extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
