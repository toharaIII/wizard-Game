import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftBasicFormat
import SwiftCompilerPluginMessageHandling
import SwiftParser
import SwiftDiagnostics

struct ManaCostCalculator {
    static func calculateManaCost(for spellCode: String) -> Int {
        let sourceFile = Parser.parse(source: spellCode)
        return analyzeManaCost(node: Syntax(sourceFile), depth: 1)
    }

    private static func analyzeManaCost(node: Syntax, depth: Int) -> Int {
        var manaCost = 0

        for child in node.children(viewMode: .all) {
            if let functionCall = child.as(FunctionCallExprSyntax.self), isSpellLibraryFunction(functionCall) {
                manaCost += 5 * depth
            }

            if let loop = child.as(ForStmtSyntax.self) {
                let loopCost = analyzeManaCost(node: Syntax(loop.body), depth: depth * 2)
                manaCost += loopCost * 2
            } else if let loop = child.as(WhileStmtSyntax.self) {
                let loopCost = analyzeManaCost(node: Syntax(loop.body), depth: depth * 2)
                manaCost += loopCost * 2
            } else {
                manaCost += analyzeManaCost(node: child, depth: depth)
            }
        }

        return manaCost
    }
    
    private static func isSpellLibraryFunction(_ node: FunctionCallExprSyntax) -> Bool {
        guard let calledExpression = node.calledExpression.as(MemberAccessExprSyntax.self) else {
            return false
        }
        
        let spellFunctions = ["ball", "willOWisp", "kindling", "icicle", "hail", "permafrost", "teleport", "portal", "minorWard", "majorWard", "aegis", "mirror", "purify", "shroud"]
        return spellFunctions.contains(calledExpression.declName.baseName.text)
    }
}
