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
class battleStatus{
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
    
    init(battleId: String,
         startTime: Date,
         player1: player,
         battleTome1: [spell],
         spellsCast1: Int,
         damageDealt1: Int,
         player2: player,
         battleTome2: [spell],
         spellsCast2: Int,
         damageDealt2: Int,
         turnNumber: Int,
         battleState: battleState){
        self.battleId = battleId
        self.startTime = startTime
        self.player1 = player1
        self.battleTome1 = battleTome1
        self.spellsCast1 = spellsCast1
        self.damageDealt1 = damageDealt1
        self.player2 = player2
        self.battleTome2 = battleTome2
        self.spellsCast2 = spellsCast2
        self.damageDealt2 = damageDealt2
        self.turnNumber = turnNumber
        self.battleState = battleState
    }
}

/*stores lifetime data for a user such as username, stored and active spells, and lifetime stats aggregated from all games*/
class User{
    let id: String
    let userName: String
    
    //spell collection
    var grimoire: [spell] = []
    var battleTome: [spell] = []
    
    var activeBattles: [String: battleStatus] = [:]//dictionary of current battles
    
    //battle stats
    var wins: Int = 0
    var losses: Int = 0
    var spellsCast: Int = 0
    var damageDealt: Int = 0
    var damageTaken: Int = 0
    var rank: rankings = rankings.AdeptIII
    
    init(id: String,
         userName: String,
         grimore: [spell],
         battleTome: [spell],
         activeBattles: [String: battleStatus],
         wins: Int,
         losses: Int,
         spellsCast: Int,
         damageDealt: Int,
         damageTaken: Int,
         rank: rankings){
        self.id=id
        self.userName=userName
        self.grimoire=grimore
        self.battleTome=battleTome
        self.activeBattles=activeBattles
        self.wins=wins
        self.losses=losses
        self.spellsCast=spellsCast
        self.damageDealt=damageDealt
        self.damageTaken=damageTaken
        self.rank=rank
    }
}
