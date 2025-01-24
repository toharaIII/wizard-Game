//holds data for currently signed in user to be taken when needed for local app stuff
import Foundation

enum rankings{ //all possible player rankings
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

/*stores all data for any one player which is only important to the progression of any one battle*/
class player{
    let userId: String
    let userName: String
    
    var health: Int
    var mana: Int
    var position: position
    var restrictedVision: Bool=false
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

/*stores all information for any one battle, including that of both players along with information
 regarding the game state and grid, and is how a battle is found in the database*/
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

/*stores lifetime data for a user such as username, stored and active spells, and lifetime stats aggregated from all games*/
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
