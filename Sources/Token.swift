//
//  Token.swift
//  compiler
//
//  Created by Jared Halpern on 5/19/25.
//

import Foundation

public enum Token: Equatable, Sendable {
    /// Integer literal
    case intLiteral(Int)
    
    /// name of variable, function, etc
    case identifier(String)
    
    case plus, minus, star, slash, equal
    
    /// left-parens, right-parens, semi-colon, end-of-file
    case lparen, rparen, semicolon, eof, colon
    
    /// keywords: print
    case printKw
    
    /// keywords: var, let
    case varKw, letKw
    
    // var x: Int = 32 (type is Int)
    case typeKw(String)

    case funcKw
    
    case classKw
    
    /// left-brace "{", right-brace "}", comma, ->
    case lbrace, rbrace, comma, arrow
    
    case stringLiteral(String)
}
