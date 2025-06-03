//
//  AST.swift
//  compiler
//
//  Created by Jared Halpern
//

import Foundation

public protocol ASTNode {}
public protocol Statement: ASTNode {}
public protocol Expr: ASTNode {}

// MARK: - Objects

public struct ClassDecl: Statement {
    public let name: String
    public let statements: [Statement]
}

// MARK: - Functions

//public struct FuncDecl: Statement, ClassMember {
public struct FuncDecl: Statement {
    public let name: String
    public let parameters: [(String, TypeAnnotation)]
    public let returnType: TypeAnnotation?
    public let body: [Statement]
}

//public struct CallExpr: Expr {
//    public let callee: String
//    public let arguments: [Expr]
//}

// MARK: - Statements

/// Declaration: var x[:Type] = <expr>
public struct VarDecl: Statement {
    public let name: String
    public let type: TypeAnnotation?
    public let value: Expr
}

/// Declaration: let x[:Type] = <expr>
public struct LetDecl: Statement {
    public let name: String
    public let type: TypeAnnotation?
    public let value: Expr
}

/// Assignment: x = <expr>
public struct Assignment: Statement {
    public let name: String
    public let value: Expr
}

/// Print: print <expr>
public struct PrintStmt: Statement {
    public let expr: Expr
}

/// General expression statement
public struct ExprStmt: Statement {
    public let expr: Expr
}

// MARK: - Expressions

/// Name of variable, function, etc
public struct IdentifierExpr: Expr {
    public let name: String
}

public struct IntLiteral: Expr {
    public let value: Int
}

public struct StringLiteral: Expr {
    public let value: String
}

/// Binary operation (left op right), op token carries + - * /
public struct BinaryExpr: Expr {
    public let left: Expr
    public let op: Token
    public let right: Expr
}

// TODO: Declaration keywords: struct, enum
// TODO: Control flow keywords: if, else, switch, for, while, return
// TODO: Access control keywords: public, private, internal, fileprivate
