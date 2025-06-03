//
//  LexerFunctionTests.swift
//  compiler
//
//  Created by Jared Halpern on 5/27/25.
//

import XCTest
@testable import compiler

final class LexerFunctionTests: XCTestCase {
    
    func testLexFunctionDeclarationTokensWithReturn() throws {
        
        let source = "func add(x: Int, y: Int) -> Int { x + y }"
        let tokens = try Lexer(source).tokenize()
        
        let expected: [Token] = [
            .funcKw,
            .identifier("add"),
            .lparen,
            .identifier("x"), .colon, .typeKw("Int"),
            .comma,
            .identifier("y"), .colon, .typeKw("Int"),
            .rparen,
            .arrow,
            .typeKw("Int"),
            .lbrace,
            .identifier("x"), .plus, .identifier("y"),
            .rbrace,
            .eof
        ]
        
        var mismatch: String = ""
        
        for (i, e) in expected.enumerated() {
            if tokens[i] != e {
                mismatch += "\(tokens[i])------- Expected: \(e)"
            }
        }
        XCTAssertEqual(tokens, expected, "Lexer should emit func‐keyword, identifiers, punctuation, arrow, braces and eof in the right order.\nMismatch with: \(mismatch)")
    }
    
    func testLexFunctionDeclarationTokensWithoutReturn() throws {
        
        let source = "func add(x: Int, y: Int) { x + y }"
        let tokens = try Lexer(source).tokenize()
        
        let expected: [Token] = [
            .funcKw,
            .identifier("add"),
            .lparen,
            .identifier("x"), .colon, .typeKw("Int"),
            .comma,
            .identifier("y"), .colon, .typeKw("Int"),
            .rparen,
            .lbrace,
            .identifier("x"), .plus, .identifier("y"),
            .rbrace,
            .eof
        ]
        
        var mismatch: String = ""
        
        for (i, e) in expected.enumerated() {
            if tokens[i] != e {
                mismatch += "\(tokens[i])------- Expected: \(e)"
            }
        }
        XCTAssertEqual(tokens, expected, "Lexer should emit func‐keyword, identifiers, punctuation, arrow, braces and eof in the right order.\nMismatch with: \(mismatch)")
    }
    
    func testLexFunctionDeclarationTokensWithoutParameters() throws {
        
        let source = "func add() { x + y }"
        let tokens = try Lexer(source).tokenize()
        
        let expected: [Token] = [
            .funcKw,
            .identifier("add"),
            .lparen,
            .rparen,
            .lbrace,
            .identifier("x"), .plus, .identifier("y"),
            .rbrace,
            .eof
        ]
        
        var mismatch: String = ""
        
        for (i, e) in expected.enumerated() {
            if tokens[i] != e {
                mismatch += "\(tokens[i])------- Expected: \(e)"
            }
        }
        XCTAssertEqual(tokens, expected, "Lexer should emit func‐keyword, identifiers, punctuation, arrow, braces and eof in the right order.\nMismatch with: \(mismatch)")
    }
}
