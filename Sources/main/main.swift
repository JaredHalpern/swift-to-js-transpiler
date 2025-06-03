import Foundation

let args = CommandLine.arguments

if args.count < 2 {
    printUsage()
    exit(0)
}

switch args[1] {
    
case "build":
    let fm = FileManager.default
    
    let cwd = fm.currentDirectoryPath
    
    do {
        let swiftFiles = try fm.contentsOfDirectory(atPath: cwd)
            .filter { $0.hasSuffix(".swift") && $0 != "main.swift" }
        
        guard !swiftFiles.isEmpty else {
            print("No Swift files found to build in \(cwd)")
            exit(0)
        }
        
        for file in swiftFiles {
            let fullPath = cwd + "/" + file
            let source = try String(contentsOfFile: fullPath, encoding: .utf8)
            
            let tokens = try Lexer(source).tokenize()
            let ast = Parser(tokens).parseProgram()
            let js = CodeGenerator().generate(ast)
            
            let jsName = file.replacingOccurrences(of: ".swift", with: ".js")
            let outURL = URL(fileURLWithPath: cwd).appendingPathComponent(jsName)
            
            try js.write(to: outURL, atomically: true, encoding: .utf8)
            
            print("Built \(jsName)")
        }
    } catch {
        fputs("Build error: \(error)\n", stderr)
        exit(1)
    }
    
case "repl":
    let repl = REPL()
    repl.run()
        
case "pipe":
    readStandardInput()
    
case "--help", "-h":
    printUsage()
    
default:
    print("Unknown command: \(args[1])\n")
    printUsage()
    exit(1)
}

// MARK: - Functions

func printUsage() {
    print("Usage: compiler <command>\n")
    print("Commands:")
    print("  build    Compile all .swift files in current directory to .js")
    print("  repl     Run interactive REPL")
    print("  pipe     Read all data from standard input")
    print("  --help   Show this help message")
}

func readStandardInput() {
    
    // Ensure stdin is piped data, not a terminal
    if isatty(STDIN_FILENO) != 0 {
        fputs("Error: No input received. Please pipe Swift-subset code into stdin.\n", stderr)
        exit(1)
    }
    
    // Read all data from stdin
    let inputData = FileHandle.standardInput.readDataToEndOfFile()
    guard let source = String(data: inputData, encoding: .utf8), !source.isEmpty else {
        fputs("Error: Failed to read input or input is empty.\n", stderr)
        exit(1)
    }
    
    do {
        // Lexing
        let lexer = Lexer(source)
        let tokens = try lexer.tokenize()
        
        // Parsing
        let parser = Parser(tokens)
        let ast = parser.parseProgram()
        
        // AST Output
        print("=== AST ===")
        ASTPrinter().printStatements(ast)
        
        // Code Generation
        print("\n=== Generated JS ===")
        let jsCode = CodeGenerator().generate(ast)
        print(jsCode)
    } catch {
        print("Error: \(error)")
    }
}
