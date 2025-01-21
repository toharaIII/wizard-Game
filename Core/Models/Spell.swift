//defines what makes up a spell, references to load data into a templated class for all of the users created spells
import Foundation

enum spellError: Error{
    case insufficientMana(required: Int, available: Int)
    case invalidTarget(position: position)
    case executionFailed(reason: String)
}

struct spell{
    let name: String
    let description: String
    let author: String
    
    typealias spellLogic = (spellContext) -> [spellEffect]
    let execute: spellLogic
    
    let manaCost: Int
    let sourceCode: String
    let createdAt: Date
    let lastModified: Date
    
    var lastExecutionSuccess: Bool?
    var lastError: String?
}

struct spellContext{
    let casterPosition: position
    let target: position
    let battlefield: [[tile]] //yet to be defined, expect error from this for the time being
    
    let playerHealth: Int
    let playerMana: Int
    let turnNumber: Int
    
    let tileEffects: [spellEffect]
}
