//holds data for currently signed in user to be taken when needed for local app stuff
import Foundation

enum rankings{
    case NoviceIII
    case NoviceII
    case NoviceI
    case ApprenticeIII
    case ApprenticeII
    case ApprenticeI
    case AdeptIII
    case AdeptII
    case AdeptI
    case MasterIII
    case MasterII
    case MasterI
    case ArchmageIII
    case ArchmageII
    case ArchmageI
}

struct battleStatus{
    var battleTome: [spell]
    
    let battleId: String
    let opponent: String
    let startTime: Date
    let lastMoveTime: Date
    
    var health: Int
    var mana: Int
    var position: position
    var spellsCast: Int
    var damageDealt: Int
    
    var isImmobalized: Bool
    var isYourTurn: Bool
    var turnNumber: Int
    var battleState: battleState //reference to the actual battle
}

struct User{
    let id: String
    let userName: String
    
    //game Stats
    var health: Int
    var mana: Int
    var position: position
    
    //spell collection
    var grimoire: [spell]
    var battleTome: [spell]
    
    var activeBattles: [String: battleStatus] //dictionary of current battles
    
    //battle stats
    var wins: Int
    var losses: Int
    var spellsCast: Int
    var damageDealt: Int
    var damageTaken: Int
    var rank: rankings
}
