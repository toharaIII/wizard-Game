//defines what makes up a spell, references to load data into a templated class for all of the users created spells
import Foundation

enum spellError: Error{ //all possible error messages during spell compilation in spell creator
    case insufficientMana(required: Int, available: Int)
    case invalidTarget(position: position)
    case executionFailed(reason: String)
}

/*
 designed to hold a compiled spell or spell in progress of being created so that it is viewed in the grimoire or battle tome of a player, contains all necessary data to do so
 */
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

/*
designed to hold information which will be relevant to a spell as it is casted so that existing effects on that tile and/or player can be added to, canceled out, calculated, etc
*/
struct spellContext{
    let casterPosition: position
    let target: position
    let battlefield: [[tile]]
    let turnNumber: Int
    
    let tileEffects: [spellEffect]
}
