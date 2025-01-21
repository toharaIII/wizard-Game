//keeps track of occurances during a battle
import Foundation

enum gameState {
    case running
    case gameOver
}

class battleState{
    var curGameState: gameState
    var turnOrder: [User]=[]
    var currentPlayerIndex: Int=0
    var tiles: [[tile]]
    var spellContexts: [spellContext]=[]
    var winner: User?
    
    init(tiles: [[tile]]){
        self.tiles=tiles
        self.curGameState=gameState.running
    }
    
    func nextTurn(){ //turn management
        guard curGameState == gameState.running else {return}
        currentPlayerIndex = (currentPlayerIndex+1)%turnOrder.count //like this so in future we can easily impliment more than 2 player battles
        let currentPlayer=turnOrder[currentPlayerIndex]
        processTurn(for: currentPlayer) //want to put this in a separate file
        //handles +mana, move, cast a spell, and therefore should be built at the end of models
    }
    
    func applyEffects(){
        for context in spellContexts{
            for effect in context.tileEffects{
                handleEffect(effect: effect, for: context)
            }
        }
    }
    
    func handleEffect(effect: spellEffect, for context: spellContext){
        //good luck on this guy
    }
    
    func calculateDamage(from effect: spellEffect, with context: spellContext) -> Int{
        var totalDamage = effect.damage
        if effect.damageReduction>0{
            totalDamage -= effect.damageReduction
        }
        return totalDamage
    }
    
    func movePlayer(from start: position, to end: position){
        guard curGameState == gameState.running else {return}
        updateTileOccupation(from: start, to: end)
    }
    
    func updateTileOccupation(from start: position, to end: position){
        tiles[start.x][start.y].isOccupied=false
        tiles[end.x][end.y].isOccupied=true
    }
    
    func getTile(at position: position) -> tile? {
        guard position.x >= 0, position.x < tiles.count,
              position.y >= 0, position.y < tiles[0].count else { return nil}
        return tiles[position.x][position.y]
    }
    
    func updateTileEffects(for position: position, with effect: spellEffect){
        guard var targetTile = getTile(at: position) else {return}
        targetTile.effects.append(effect)
    }
    
    func clearTileEffects(for position: position){
        guard var targetTile = getTile(at: position) else {return}
        targetTile.effects.removeAll()
    }
    
    func checkVictory(){
        if turnOrder.contains(where: {$0.health <= 0}){
            curGameState = gameState.gameOver
            winner=turnOrder.first {$0.health > 0} //will need to change this if more than 2 ppl, maybe?
        }
    }
}
