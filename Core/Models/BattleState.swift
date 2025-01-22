//keeps track of occurances during a battle
import Foundation

enum gameState {
    case running
    case gameOver
}

class battleState{
    var curGameState: gameState
    var turnOrder: [player]=[]
    var currentPlayerIndex: Int=0
    let lastMoveTime: Date
    
    var tiles: [[tile]]
    var spellContexts: [spellContext]=[]
    var winner: player?
    
    init(tiles: [[tile]]){
        self.tiles=tiles
        self.curGameState=gameState.running
    }
    
    func nextTurn(){ //turn management
        guard curGameState == gameState.running else {return}
        currentPlayerIndex = (currentPlayerIndex+1)%turnOrder.count //rotate thru ALL players
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
        return max(0, totalDamage)
    }
    
    func movePlayer(player: player, to newTile: tile){
        guard curGameState == gameState.running else {return}
        guard var currentTile=getTile(at: player.position) else {return}
        
        currentTile.isOccupied=false
        player.position=newTile.position
        tiles[newTile.position.x][newTile.position.y].isOccupied=true
    }
    
    func getTile(at position: position) -> tile? {
        guard position.x >= 0, position.x < tiles.count,
              position.y >= 0, position.y < tiles[0].count else { return nil}
        return tiles[position.x][position.y]
    }
    
    func updateTileEffects(for position: position, with effect: spellEffect){
        guard var targetTile = getTile(at: position) else { return }
        targetTile.effects.append(effect)
        tiles[position.x][position.y] = targetTile
    }
    
    func clearTileEffects(for position: position) {
        guard var targetTile = getTile(at: position) else { return }
        targetTile.effects.removeAll()
        tiles[position.x][position.y] = targetTile
    }
    
    func checkVictory(){
        if let defeatedPlayer = turnOrder.first(where: {$0.health <= 0}){
            curGameState=gameState.gameOver
            winner = turnOrder.first { player in
                player !== defeatedPlayer && player.health > 0
            }
            return
        }
        
        if turnOrder.count==1{
            curGameState=gameState.gameOver
            winner=turnOrder.first
            return
        }
        
        let timeElapsed=Date().timeIntervalSince(lastMoveTime)
        if timeElapsed > 24*60*60{
            let losingPlayer=turnOrder[currentPlayerIndex]
            curGameState=gameState.gameOver
            winner=turnOrder.first {$0.userId != losingPlayer.userId}
        }
    }
}
