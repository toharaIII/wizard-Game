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

class player{
    let userId: String
    let userName: String
    
    var health: Int
    var mana: Int
    var position: position
    var isImmobalized: Bool=false
    var activeEffects: [spellEffect]=[]
    
    init(userId: String, userName: String, health: Int, mana: Int, position: position){
        self.userId=userId
        self.userName=userName
        self.health=health
        self.mana=mana
        self.position=position
    }
}

struct battleStatus{
    let battleId: String
    let startTime: Date
    
    var player1: player
    let battleTome1: [spell]
    var spellsCast1: Int
    var damageDealt1: Int
    
    var player2: player
    let battleTome2: [spell]
    var spellsCast2: Int
    var damageDealt2: Int
    
    var turnNumber: Int
    var battleState: battleState //reference to the actual battle
}

struct User{
    let id: String
    let userName: String
    
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
