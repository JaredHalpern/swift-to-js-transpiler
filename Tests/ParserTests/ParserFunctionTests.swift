//
//  ParserFunctionTests.swift
//  compiler
//
//  Created by Jared Halpern on 5/27/25.
//

import XCTest
@testable import compiler

final class ParserFunctionTests: XCTestCase {
    
    func testParseFunctionDeclaration() throws {
        let source = "func add(x: Int, y: Int) -> Int { x + y }"
        let tokens = try Lexer(source).tokenize()
        let parser = Parser(tokens)
        let program = parser.parseProgram()
        
        XCTAssertEqual(tokens.count, 19, "Unexpected number of tokens")
        XCTAssertEqual(parser.errors.count, 0, "Parser error count should be zero.\n-----> Errors: \(parser.errors)")
        
        // Expect exactly one top‐level statement, and that it's a FuncDecl
        XCTAssertEqual(program.count, 1)
        guard let funcDecl = program.first as? FuncDecl else {
            return XCTFail("Expected a FuncDecl node")
        }
        
        // Name + signature
        XCTAssertEqual(funcDecl.name, "add")
        XCTAssertEqual(funcDecl.parameters.map { $0.0 }, ["x", "y"])
        XCTAssertEqual(funcDecl.parameters.map { $0.1.rawValue }, ["Int", "Int"])
        XCTAssertEqual(funcDecl.returnType?.rawValue, "Int")
        
        // Body contains a single expression statement: x + y
        XCTAssertEqual(funcDecl.body.count, 1)
        
        guard
            let exprStmt = funcDecl.body.first as? ExprStmt,
            let binExpr = exprStmt.expr as? BinaryExpr else
        {
            return XCTFail("Expected body to be a single infix‐expression statement")
        }
        
        XCTAssertEqual((binExpr.left as? IdentifierExpr)?.name, "x")
        XCTAssertEqual(binExpr.op, .plus)
        XCTAssertEqual((binExpr.right as? IdentifierExpr)?.name, "y")
    }
    
    //        func testParseFunctionCallExpression() throws {
    //            let source = "add(2, 3)"
    //            let tokens = Lexer(source).tokenize()
    //            let parser = Parser(tokens)
    //            let program = try parser.parseProgram()
    //
    //            XCTAssertEqual(program.count, 1)
    //            guard let exprStmt = program.first as? ExprStmt,
    //                  let call = exprStmt.expr as? CallExpr else {
    //                return XCTFail("Expected a CallExpr at top level")
    //            }
    //
    //            XCTAssertEqual(call.callee, "add")
    //            XCTAssertEqual(call.arguments.count, 2)
    //            XCTAssertEqual((call.arguments[0] as? IntLiteral)?.value, 2)
    //            XCTAssertEqual((call.arguments[1] as? IntLiteral)?.value, 3)
    //        }
}
