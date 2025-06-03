//
//  CodeGenerator.swift
//  compiler
//
//  Created by Jared Halpern
//

class CodeGenerator {
    
    func generate(_ statements: [Statement]) -> String {
        statements.map { genStatement($0) }.joined(separator: "\n")
    }
    
    private func genStatement(_ statement: Statement) -> String {
        
        switch statement {
        case let printStatement as PrintStmt:
            return "console.log(\(genExpression(printStatement.expr)));"
            
        case let expressionStatement as ExprStmt:
            return genExpression(expressionStatement.expr) + ";"
            
        case let assignmentStatement as Assignment:
            return "\(assignmentStatement.name) = \(genExpression(assignmentStatement.value));"
            
        case let letDecl as LetDecl:
            return genLetDecl(letDecl)
            
        case let varDecl as VarDecl:
            return genVarDecl(varDecl)
            
        case let funcDecl as FuncDecl:
            return genFunc(funcDecl)
            
        case let cl as ClassDecl:
            return genClass(cl)
            
        default:
            return ""
        }
    }
    
    private func genExpression(_ expression: Expr) -> String {
        switch expression {
            
        case let str as StringLiteral:
            // escape backslashes and quotes for JS
            let esc = str.value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\t", with: "\\t")
            return "\"\(esc)\""
            
        case let ident as IdentifierExpr:
            return ident.name
            
        case let intLit as IntLiteral:
            return "\(intLit.value)"
            
        case let binExpr as BinaryExpr:
            let opStr: String
            
            // TODO: more ops -> expressions
            switch binExpr.op {
            case .plus:
                opStr = "+"
            case .minus:
                opStr = "-"
            case .star:
                opStr = "*"
            case .slash:
                opStr = "/"
            default:
                opStr = "?"
            }
            return "(\(genExpression(binExpr.left)) \(opStr) \(genExpression(binExpr.right)))"
        default:
            fatalError("Unknown expr in codegen")
        }
    }
}

extension CodeGenerator {
    
    private func genVarDecl(_ varDecl: VarDecl) -> String {
        // Swift & JS `let` are block-scoped. `let` in Swift and JS are not hoisted and thus exist in temporal dead zone until declared (in JS).
        // The above scoping is desirable so we don't leak variables in JS.
        return "let \(varDecl.name) = \(genExpression(varDecl.value));"
    }
    
    private func genLetDecl(_ varDecl: LetDecl) -> String {
        // Swift & JS `let` and `const` are block-scoped and not hoisted / exist in temporal dead zone until declared (in JS).
        // The above scoping is desirable so we don't leak variables in JS.
        return "const \(varDecl.name) = \(genExpression(varDecl.value));"
    }
    
    private func genFunc(_ funcDecl: FuncDecl) -> String {
        
        var body = ""
        
        let params = funcDecl.parameters.map { $0.0 }.joined(separator: ", ")
        
        for (i, stmt) in funcDecl.body.enumerated() {
            
            // if last statement in body, turn into a return statement
            if
                i == funcDecl.body.count - 1,
                let exprStatement = stmt as? ExprStmt,
                funcDecl.returnType != nil
            {
                body += "  return \(genExpression(exprStatement.expr));\n"
            } else {
                body += "    \(genStatement(stmt))\n"
            }
        }
        
        return "function \(funcDecl.name)(\(params)) {\n\(body)}"
    }
    
    private func genClass(_ classDecl: ClassDecl) -> String {
        
        var out = "class \(classDecl.name) {\n"
        
        // TODO: maybe emit a default constructor
        
        for member in classDecl.statements {
            
            switch member {
            
            case let varDecl as VarDecl:
                // ES2022+, declare and init fields on the class body, not through constructor.
                let jsVal = genExpression(varDecl.value)
                out += "     this.\(varDecl.name) = \(jsVal);\n"
            case let letDecl as LetDecl:
                // ES2022+, declare and init fields on the class body, not through constructor.
                let jsLet = genExpression(letDecl.value)
                out += "     this.\(jsLet) = \(jsLet);\n"
                
            case let funcDecl as FuncDecl:
                // here method.name == "init" -> constructor, else -> instance method
                out += genFunc(funcDecl)
                

            default:
                break
            }
        }
        out += "  }\n"
        return out
    }
}
