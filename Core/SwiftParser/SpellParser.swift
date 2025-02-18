import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftBasicFormat
import SwiftCompilerPluginMessageHandling
import SwiftParser
import SwiftDiagnostics

struct SpellAnalysisResult {
    let isValid: Bool
    let errors: [String]
    let functionCount: Int
    let loopCount: Int
    let maxNestingDepth: Int
}

struct SpellParser {
    static func parseSpell(_ code: String) -> SpellAnalysisResult {
        let sourceFile = Parser.parse(source: code)
        var diagnostics: [String] = []
        var functionCount = 0
        var loopCount = 0
        var maxNestingDepth = 0

        validateSyntax(node: Syntax(sourceFile), diagnostics: &diagnostics)
        analyzeSpellStructure(node: Syntax(sourceFile), depth: 1, functionCount: &functionCount, loopCount: &loopCount, maxNestingDepth: &maxNestingDepth)

        return SpellAnalysisResult(
            isValid: diagnostics.isEmpty,
            errors: diagnostics,
            functionCount: functionCount,
            loopCount: loopCount,
            maxNestingDepth: maxNestingDepth)
    }

    private static func validateSyntax(node: Syntax, diagnostics: inout [String]) {
        for child in node.children(viewMode: .all) {
            if let token = child.as(TokenSyntax.self), token.presence == SourcePresence.missing {
                    diagnostics.append("Error: Missing token at position \(token.position)")
            }
            validateSyntax(node: child, diagnostics: &diagnostics)
        }
    }

    private static func analyzeSpellStructure(node: Syntax, depth: Int, functionCount: inout Int, loopCount: inout Int, maxNestingDepth: inout Int) {
        maxNestingDepth = max(maxNestingDepth, depth)
            
        for child in node.children(viewMode: .all) {
            if let functionCall = child.as(FunctionCallExprSyntax.self) {
                if isSpellLibraryFunction(functionCall) {
                    functionCount += 1
                }
            }
                
            if isControlFlowStatement(child) {
                loopCount += 1
                analyzeSpellStructure(node: child, depth: depth + 1, functionCount: &functionCount, loopCount: &loopCount, maxNestingDepth: &maxNestingDepth)
            } else {
                analyzeSpellStructure(node: child, depth: depth, functionCount: &functionCount, loopCount: &loopCount, maxNestingDepth: &maxNestingDepth)
            }
        }
    }
        
    private static func isSpellLibraryFunction(_ node: FunctionCallExprSyntax) -> Bool {
        guard let calledExpression = node.calledExpression.as(MemberAccessExprSyntax.self)
        else {
            return false
        }
            
        let spellFunctions = ["ball", "willOWisp", "kindling", "icicle", "hail", "permafrost", "teleport", "portal", "minorWard", "majorWard", "aegis", "mirror", "purify", "shroud"]
        return spellFunctions.contains(calledExpression.declName.baseName.text)
    }
        
    private static func isControlFlowStatement(_ node: Syntax) -> Bool {
        return node.is(IfExprSyntax.self) || node.is(ForStmtSyntax.self) || node.is(WhileStmtSyntax.self)
    }
}
