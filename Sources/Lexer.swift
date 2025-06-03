//
//  Lexer.swift
//  compiler
//
//  Created by Jared Halpern
//

import Foundation

public enum LexerError: Error {
    case unexpectedSmartQuote
    
    var message: String {
        switch self {
        case .unexpectedSmartQuote:
            return "Unexpected SmartQuote received. Replace with ASCII quotation marks (U+0022) as string delimiter instead of U+201C and U+201D."
        }
    }
}

protocol LexerConformable {
    func tokenize() throws -> [Token]
}

public final class Lexer: LexerConformable {
    private let input: [Character]
    private var index = 0
    
    init(_ input: String) {
        self.input = Array(input)
    }
    
    func tokenize() throws -> [Token] {
        
        var tokens = [Token]()
        
        while let c = peek() {
            
            switch c {
            case " ", "\t", "\n", "\r": skipWhitespace()
            case "+": advance(); tokens.append(.plus)
            case "*": advance(); tokens.append(.star)
            case "/": advance(); tokens.append(.slash)
            case "=": advance(); tokens.append(.equal)
            case "(": advance(); tokens.append(.lparen)
            case ")": advance(); tokens.append(.rparen)
            case "{": advance(); tokens.append(.lbrace)
            case "}": advance(); tokens.append(.rbrace)
            case ",": advance(); tokens.append(.comma)
            case ":": advance(); tokens.append(.colon)
            case ";": advance(); tokens.append(.semicolon)
            case "\"": advance(); tokens.append(lexStringLiteral())
            case "-":
                advance()
                if peek() == ">" {
                    advance()
                    tokens.append(.arrow)
                } else {
                    tokens.append(.minus)
                }
                
            case let digit where digit.isNumber:
                tokens.append(lexNumber())
                
            case let letter where letter.isLetter:
                tokens.append(lexIdentifier())
                // TODO: THIS DOESNT SEEM TO WORK
            case "\u{201C}","\u{201D}" :
                throw LexerError.unexpectedSmartQuote
            default:
                advance()
            }
        }
        
        tokens.append(.eof)
        
        return tokens
    }
    
    private func lexStringLiteral() -> Token {
        var value = ""
        
        while let c = peek() {
            
            // Check for closing quote
            if c == "\"" {
                advance()
                break
            }
            
            // Handle escape cases
            if c == "\\" {
                advance()
                if let esc = peek() {
                    switch esc {
                    case "\"":
                        value.append("\"")
                    case "\\":
                        value.append("\\")
                    case "n":
                        value.append("\n")
                    case "t":
                        value.append("\t")
                    default:
                        value.append(esc)
                    }
                    advance()
                }
            } else {
                value.append(c)
                advance()
            }
        }
        
        return .stringLiteral(value)
    }
    
    /// Lex into a token
    /// - Returns: Tokenized keyword
    private func lexIdentifier() -> Token {
        
        var id = ""
        
        while let c = peek(), c.isLetter {
            id.append(c)
            advance()
        }
        
        switch id {
        case "class":
            return .classKw
        case "print":
            return .printKw
        case "var":
            return .varKw
        case "let":
            return .letKw
        case "Int", "Bool", "String": // add more built-in types
            return .typeKw(id)
        case "func":
            return .funcKw
        default:
            return .identifier(id)
        }
    }
}

// MARK: - Private

extension Lexer {
    
    private func peek() -> Character? {
        index < input.count ? input[index] : nil
    }
    
    @discardableResult
    private func advance() -> Character? {
        defer { index += 1 }
        return peek()
    }
    
    private func skipWhitespace() {
        while let c = peek(), c.isWhitespace {
            advance()
        }
    }
    
    private func lexNumber() -> Token {
        var num = ""
        
        while let c = peek(), c.isNumber {
            num.append(c)
            advance()
        }
        
        return .intLiteral(Int(num)!)
    }
}
