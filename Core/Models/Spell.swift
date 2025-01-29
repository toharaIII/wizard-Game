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
    
    let effect: spellEffect
    
    let manaCost: Int
    let sourceCode: String
    let createdAt: Date
    let lastModified: Date
    
    var lastExecutionSuccess: Bool?
    var lastError: String?
    
    init(name: String,
         description: String,
         author: String,
         effect: spellEffect,
         manaCost: Int,
         sourceCode: String,
         createdAt: Date=Date(),
         lastModified: Date=Date()){
        self.name=name
        self.description=description
        self.author=author
        self.effect=effect
        self.manaCost=manaCost
        self.sourceCode=sourceCode
        self.createdAt=createdAt
        self.lastModified=lastModified
    }
}
