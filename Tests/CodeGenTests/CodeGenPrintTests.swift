//
//  CodeGenPrintTests.swift
//  compiler
//
//  Created by Jared Halpern on 5/22/25.
//

import XCTest
@testable import compiler

final class CodeGenPrintTests: XCTestCase {
    
    func testCodeGeneratorPrint() throws {
        let source = "print 1 + 2;"
        let tokens = try Lexer(source).tokenize()
        let stmts = Parser(tokens).parseProgram()
        
        let js = CodeGenerator().generate(stmts)
        
        XCTAssertEqual(js, "console.log((1 + 2));")
    }
}
