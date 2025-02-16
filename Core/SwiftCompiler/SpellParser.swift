import SwiftSyntax
import SwiftBasicFormat
import SwiftCompilerPluginMessageHandling
import SwiftParser
import SwiftDiagnostics

struct SpellParser {
    static func parseSpell(_ code: String) -> (isValid: Bool, errors: [String]) {
        let sourceFile = Parser.parse(source: code)
        var diagnostics: [String]=[]
        
        validateSyntax(node: Syntax(sourceFile), diagnostics: &diagnostics)
        
        let isValid=diagnostics.isEmpty
        return (isValid, diagnostics)
    }
    
    private static func validateSyntax(node: Syntax, diagnostics: inout [String]){
        for child in node.children(viewMode: .all){
            if let token=child.as(TokenSyntax.self), token.presence == SourcePresence.missing{
                diagnostics.append("Error: Missing token at position \(token.position)")
            }
            validateSyntax(node: child, diagnostics: &diagnostics)
        }
    }
}
