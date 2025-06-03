// REPL.swift
//  compiler
//
//  Created by Jared Halpern
//

import Foundation

public final class REPL {
    private let prompt = "> "

    public func run() {
        
        print("REPL v0.1\n")
        
        while true {
            
            // Print prompt without newline
            print(prompt, terminator: "")
            
            guard let line = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !line.isEmpty
            else {
                // EOF or empty line: exit REPL
                print("Goodbye!")
                break
            }

            switch line {
            case ":quit", "quit", "exit", "bye", "goodbye":
                print("Goodbye!")
                return
                
            default:
                do {
                    // Lex
                    let tokens = try Lexer(line).tokenize()
                    
                    // Parse
                    let parser = Parser(tokens)
                    let stmts = parser.parseProgram()
                    
                    // Report any parse errors
                    if !parser.errors.isEmpty {
                        parser.errors.forEach { print($0) }
                        continue
                    }
                    
                    // Print AST
                    ASTPrinter().printStatements(stmts)
                    
                    // Generate and print JS
                    let js = CodeGenerator().generate(stmts)
                    
                    print(js)
                } catch {
                    print("Error while lexing: \(error)")
                }
            }
        }
    }
}
