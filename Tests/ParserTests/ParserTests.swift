// compilerTests.swift
//  compilerTests
//
//  Created by Jared Halpern
//

import XCTest
@testable import compiler

final class CompilerTests: XCTestCase {
    
    // Parsing a lone integer literal as an ExprStmt wrapping an IntLiteral
    func testParserIntLiteralStatement() throws {
        let source = "42;"
        let tokens = try Lexer(source).tokenize()
        let parser = Parser(tokens)
        let stmts = parser.parseProgram()
        XCTAssertEqual(stmts.count, 1)

        guard let exprStmt = stmts.first as? ExprStmt,
              let lit = exprStmt.expr as? IntLiteral
        else {
            XCTFail("Expected an ExprStmt wrapping an IntLiteral")
            return
        }
        XCTAssertEqual(lit.value, 42)
    }

    // Verifying correct precedence in a binary expression (1 + 2 * 3)
    func testParserBinaryExpressionPrecedence() throws {
        let source = "1 + 2 * 3;"
        let tokens = try Lexer(source).tokenize()
        let stmts = Parser(tokens).parseProgram()
        guard let exprStmt = stmts.first as? ExprStmt,
              let top = exprStmt.expr as? BinaryExpr
        else {
            XCTFail("Expected top-level BinaryExpr"); return
        }
        
        // Should parse as 1 + (2 * 3)
        XCTAssertEqual(top.op, .plus)
        XCTAssertTrue(top.left is IntLiteral)
        XCTAssertEqual((top.left as! IntLiteral).value, 1)

        guard let right = top.right as? BinaryExpr else {
            XCTFail("Expected nested BinaryExpr"); return
        }
        XCTAssertEqual(right.op, .star)
        XCTAssertEqual((right.left as! IntLiteral).value, 2)
        XCTAssertEqual((right.right as! IntLiteral).value, 3)
    }

    func testVarDeclWithType() throws {
      let code = "var flag: Bool = true;"
      let tokens = try Lexer(code).tokenize()
      let parser = Parser(tokens)
      let stmts = parser.parseProgram()

      XCTAssertEqual(stmts.count, 1)
        
      guard let decl = stmts.first as? VarDecl else {
        XCTFail("Expected VarDecl"); return
      }
        
      XCTAssertEqual(decl.name, "flag")
      XCTAssertEqual(decl.type, .bool)
        
      // note: `true` isn’t a literal yet, so it'll parse as an IdentifierExpr("true")
    }
    
    func testParserPrintStatement() throws {
            let source = "print 5;"
            let tokens = try Lexer(source).tokenize()
            let stmts = Parser(tokens).parseProgram()
            XCTAssertEqual(stmts.count, 1)
            guard let printStmt = stmts.first as? PrintStmt else {
                XCTFail("Expected PrintStmt"); return
            }
            guard let lit = printStmt.expr as? IntLiteral else {
                XCTFail("Expected IntLiteral"); return
            }
            XCTAssertEqual(lit.value, 5)
        }

        func testParserVariableDeclarationWithoutType() throws {
            let source = "var x = 10;"
            let tokens = try Lexer(source).tokenize()
            let stmts = Parser(tokens).parseProgram()
            XCTAssertEqual(stmts.count, 1)
            guard let decl = stmts.first as? VarDecl else {
                XCTFail("Expected VarDecl"); return
            }
            XCTAssertEqual(decl.name, "x")
            XCTAssertNil(decl.type)
            XCTAssertTrue(decl.value is IntLiteral)
            XCTAssertEqual((decl.value as! IntLiteral).value, 10)
        }

        func testParserLetDeclarationWithIntType() throws {
            let source = "let y: Int = 20;"
            let tokens = try Lexer(source).tokenize()
            let stmts = Parser(tokens).parseProgram()
            XCTAssertEqual(stmts.count, 1)
            guard let decl = stmts.first as? LetDecl else {
                XCTFail("Expected LetDecl"); return
            }
            XCTAssertEqual(decl.name, "y")
            XCTAssertEqual(decl.type, .int)
            XCTAssertTrue(decl.value is IntLiteral)
            XCTAssertEqual((decl.value as! IntLiteral).value, 20)
        }

        func testParserAssignmentStatement() throws {
            let source = "x = 7;"
            let tokens = try Lexer(source).tokenize()
            let stmts = Parser(tokens).parseProgram()
            XCTAssertEqual(stmts.count, 1)
            guard let assign = stmts.first as? Assignment else {
                XCTFail("Expected Assignment"); return
            }
            XCTAssertEqual(assign.name, "x")
            XCTAssertTrue(assign.value is IntLiteral)
            XCTAssertEqual((assign.value as! IntLiteral).value, 7)
        }

        func testParserParenthesesPrecedence() throws {
            let source = "(1 + 2) * 3;"
            let tokens = try Lexer(source).tokenize()
            let stmts = Parser(tokens).parseProgram()
            guard let exprStmt = stmts.first as? ExprStmt,
                  let top = exprStmt.expr as? BinaryExpr
            else {
                XCTFail("Expected BinaryExpr"); return
            }
            XCTAssertEqual(top.op, .star)
            guard let left = top.left as? BinaryExpr else {
                XCTFail("Expected nested BinaryExpr"); return
            }
            
            XCTAssertEqual(left.op, .plus)
            XCTAssertEqual((left.left as! IntLiteral).value, 1)
            XCTAssertEqual((left.right as! IntLiteral).value, 2)
            XCTAssertEqual((top.right as! IntLiteral).value, 3)
        }

        func testParserMultipleMultiplicativeOperations() throws {
            let source = "4 * 2 / 8;"
            let tokens = try Lexer(source).tokenize()
            let stmts = Parser(tokens).parseProgram()
            
            guard let exprStmt = stmts.first as? ExprStmt,
                  let top = exprStmt.expr as? BinaryExpr
            else {
                XCTFail("Expected BinaryExpr"); return
            }
            
            // ((4 * 2) / 8)
            XCTAssertEqual(top.op, .slash)
            guard let left = top.left as? BinaryExpr else {
                XCTFail("Expected left nested BinaryExpr"); return
            }
            
            XCTAssertEqual(left.op, .star)
            XCTAssertEqual((left.left as! IntLiteral).value, 4)
            XCTAssertEqual((left.right as! IntLiteral).value, 2)
            XCTAssertEqual((top.right as! IntLiteral).value, 8)
        }

        func testParserErrorRecovery() throws {
            let source = "var = 5;"
            let tokens = try Lexer(source).tokenize()
            let parser = Parser(tokens)
            let stmts = parser.parseProgram()
            XCTAssertTrue(stmts.isEmpty)
            XCTAssertFalse(parser.errors.isEmpty)
        }
}
