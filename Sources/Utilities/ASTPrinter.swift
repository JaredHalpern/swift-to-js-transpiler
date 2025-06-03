//
//  ASTPrinter.swift
//  compiler
//
//  Created by Jared Halpern
//

import Foundation

public final class ASTPrinter {
    public init() {}

    public func printStatements(_ stmts: [Statement]) {
        stmts.forEach { dump($0, level: 0) }
    }

    private func dump(_ node: ASTNode, level: Int) {
        let indent = String(repeating: "  ", count: level)
        
        switch node {
            
        case let c as ClassDecl:
            print("\(indent)ClassDecl(\(c.name))")
            printStatements(c.statements)
            
        case let f as FuncDecl:
            let ret = f.returnType.map { " -> \($0)" } ?? ""
            print("\(indent)FuncDecl(\(f.name)\(ret))")
            
            if !f.parameters.isEmpty {
                print("\(indent)  Parameters:")
                for (paramName, paramType) in f.parameters {
                    
                    dump(StringLiteral(value: paramName), level: level + 2)
                    print("\(indent)    TypeAnnotation(\(paramType.rawValue))")
                }
            }
            
            f.body.forEach { dump($0, level: level+1) }
            
        case let s as StringLiteral:
            print("\(indent)StringLiteral(\"\(s.value)\")")
            
        case let p as PrintStmt:
            print("\(indent)PrintStmt")
            dump(p.expr, level: level+1)
            
        case let v as VarDecl:
            let annotated = v.type.map { ":\($0)" } ?? ""
            print("\(indent)VarDecl(\(v.name)\(annotated)")
            dump(v.value, level: level+1)
            
        case let v as LetDecl:
            let annotated = v.type.map { ":\($0)" } ?? ""
            print("\(indent)LetDecl(\(v.name)\(annotated)")
            dump(v.value, level: level+1)
            
        case let a as Assignment:
            print("\(indent)Assignment(\(a.name))")
            dump(a.value, level: level+1)
            
        case let e as ExprStmt:
            print("\(indent)ExprStmt")
            dump(e.expr, level: level+1)
            
        case let il as IntLiteral:
            print("\(indent)IntLiteral(\(il.value))")
            
        case let id as IdentifierExpr:
            print("\(indent)Identifier(\(id.name))")
            
        case let b as BinaryExpr:
            print("\(indent)BinaryExpr(\(b.op))")
            dump(b.left, level: level+1)
            dump(b.right, level: level+1)
            
        default:
            print("\(indent)ASTPrinter: <unknown>")
        }
    }
}
