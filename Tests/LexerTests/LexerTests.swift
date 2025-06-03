//
//  LexerTests.swift
//  compiler
//
//  Created by Jared Halpern on 5/22/25.
//

import XCTest
@testable import compiler

final class LexerTests: XCTestCase {

    func testLexIdentifiersAndKeywords() throws {
        let source = "print var let foo:Int = 12;"
        let tokens = try Lexer(source).tokenize()
        XCTAssertEqual(tokens, [
            .printKw,
            .varKw,
            .letKw,
            .identifier("foo"),
            .colon,
            .typeKw("Int"),
            .equal,
            .intLiteral(12),
            .semicolon,
            .eof
        ])
    }
    
    func testLexTypeKeywords() throws {
        let source = "Bool String Unknown"
        let tokens = try Lexer(source).tokenize()
        XCTAssertEqual(tokens, [
            .typeKw("Bool"),
            .typeKw("String"),
            .identifier("Unknown"),
            .eof
        ])
    }
    
    func testLexOperatorsAndPunctuation() throws {
            let source = "+-*/=():;"
            let tokens = try Lexer(source).tokenize()
            XCTAssertEqual(tokens, [
                .plus,
                .minus,
                .star,
                .slash,
                .equal,
                .lparen,
                .rparen,
                .colon,
                .semicolon,
                .eof
            ])
        }

        func testLexComplexWhitespace() throws {
            let source = " \t123\nfoo   +   456"
            let tokens = try Lexer(source).tokenize()
            XCTAssertEqual(tokens, [
                .intLiteral(123),
                .identifier("foo"),
                .plus,
                .intLiteral(456),
                .eof
            ])
        }
    
    func testLexerIntegerAndPlus() throws {
        let source = "123 + 456;"
        let tokens = try Lexer(source).tokenize()
        XCTAssertEqual(tokens, [
            .intLiteral(123),
            .plus,
            .intLiteral(456),
            .semicolon,
            .eof
        ])
    }
    
    func testLexerIntegerAndPlusNoSemicolon() throws {
        let source = "123 + 456"
        let tokens = try Lexer(source).tokenize()
        XCTAssertEqual(tokens, [
            .intLiteral(123),
            .plus,
            .intLiteral(456),
            .eof
        ])
    }
    
    func testColonIsTokenized() throws {
      let tokens = try Lexer(":").tokenize()
      XCTAssertEqual(tokens, [.colon, .eof])
    }
}
