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
        print("Analyzing node: \(node.syntaxNodeType), Depth: \(depth)")
        
        for child in node.children(viewMode: .all) {
            print(" - Child node: \(child.syntaxNodeType)")
            if let functionCall = child.as(FunctionCallExprSyntax.self), isSpellLibraryFunction(functionCall) {
                let cost = 5 * depth
                manaCost += cost
                print("   -> Found spell function call, cost: \(cost), Total manaCost: \(manaCost)")
            }

            if let loop = child.as(ForStmtSyntax.self) {
                print("   -> Found For Loop")
                let loopCost = analyzeManaCost(node: Syntax(loop.body), depth: depth * 2)
                manaCost += loopCost
                print("   -> Loop cost: \(loopCost), Total manaCost: \(manaCost)")
            } else if let loop = child.as(WhileStmtSyntax.self) {
                print("   -> Found While Loop")
                let loopCost = analyzeManaCost(node: Syntax(loop.body), depth: depth * 2)
                manaCost += loopCost
                print("   -> Loop cost: \(loopCost), Total manaCost: \(manaCost)")
            } else if let ifExpr = child.as(IfExprSyntax.self) {
                print("   -> Found If Statement")
                let ifCost = analyzeManaCost(node: Syntax(ifExpr.body), depth: depth * 2)
                manaCost += ifCost
                print("   -> If cost: \(ifCost), Total manaCost: \(manaCost)")
            } else {
                manaCost += analyzeManaCost(node: child, depth: depth)
            }
        }
        
        print("Returning total mana cost: \(manaCost) at Depth: \(depth)")
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
