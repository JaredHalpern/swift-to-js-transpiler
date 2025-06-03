# Transpiler for Swift to JavaScript

A transpiler for a subset of Swift. Transpiles to JavaScript.

## Components

- Lexer
- AST Printer
- Parser
- JavaScript Code Generation
- REPL

## Supports

- `var`, `let`, variables and assignments
- `int` literals
- classes
- functions
- operators `+`, `-`, `*`, `/`
- parenthesis and brackets `(`, `)`, `{`, `}`
- `print` 
- optional semicolons `;`
- Constructs an AST and prints it in human-readable form
- Generates JS (Javascript) code from Swift (subset)

## Test Coverage

- Lexer
- Parser
- CodeGen

## Other stuff

* General error recovery
* A `REPL` loop

## Command-Line Usage

Usage: `compiler <command>`  

Commands:  
  `build`    Compile all .swift files in current directory to .js  
  `repl`     Run interactive REPL  
  `pipe`     Read all data from standard input  
  `--help`   Show the help message  


## Steps to Build

1. `swift build`
2. `swift run`
3. `swift test` // run unit tests  

## To Run

`./compiler repl`  

## Additional Info

You can run commands such as:

`echo "print 1 + 2 * (3 + 4);" | ./compiler pipe`  

which will output:  
```
=== AST ===
PrintStmt
  BinaryExpr(plus)
    IntLiteral(1)
    BinaryExpr(star)
      IntLiteral(2)
      BinaryExpr(plus)
        IntLiteral(3)
        IntLiteral(4)

=== Generated JS ===
console.log((1 + (2 * (3 + 4))));
```

`cat testcode.swift | ./compiler pipe`  

which will output:  
```
=== AST ===
PrintStmt
  BinaryExpr(plus)
    IntLiteral(1)
    BinaryExpr(star)
      IntLiteral(2)
      BinaryExpr(plus)
        IntLiteral(3)
        IntLiteral(4)

=== Generated JS ===
console.log((1 + (2 * (3 + 4))));
```  