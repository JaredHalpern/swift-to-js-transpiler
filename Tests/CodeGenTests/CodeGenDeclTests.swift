//
//  CodeGenDeclTests.swift
//  compiler
//
//  Created by Jared Halpern on 5/24/25.
//

import XCTest
@testable import compiler

final class CodeGenDeclTests: XCTestCase {
    func testCodeGeneratorVarDecl() throws {
        let source = "var x = 2;"
        let tokens = try Lexer(source).tokenize()
        let stmts = Parser(tokens).parseProgram()
        
        let js = CodeGenerator().generate(stmts)
        
        XCTAssertEqual(js, "let x = 2;")
    }
    
    func testCodeGeneratorVarDeclNoSemiColon() throws {
        let source = "var x = 2"
        let tokens = try Lexer(source).tokenize()
        let stmts = Parser(tokens).parseProgram()
        
        let js = CodeGenerator().generate(stmts)
        
        XCTAssertEqual(js, "let x = 2;")
    }
    
    func testCodeGeneratorLetDecl() throws {
        let source = "let x = 2;"
        let tokens = try Lexer(source).tokenize()
        let stmts = Parser(tokens).parseProgram()
        
        let js = CodeGenerator().generate(stmts)
        
        XCTAssertEqual(js, "const x = 2;")
    }
    
    func testCodeGeneratorLetDeclNoSemiColon() throws {
        let source = "let x = 2"
        let tokens = try Lexer(source).tokenize()
        let stmts = Parser(tokens).parseProgram()
        
        let js = CodeGenerator().generate(stmts)
        
        XCTAssertEqual(js, "const x = 2;")
    }
}
