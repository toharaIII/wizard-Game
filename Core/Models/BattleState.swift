//keeps track of occurances during a battle
import Foundation

enum gameState { //all possible states a battle can be in
    case running
    case gameOver
}

/*
designed to be a battle manager and hold immediately necessary data for all players
holds all players in turn order, all spell contexts of all tiles, functions to be applied to players or tiles along with those to progress the battle such as advancing turns and checking win conditions
*/
class battleState{
    var curGameState: gameState
    var turnOrder: [player]=[]
    var currentPlayerIndex: Int=0
    let lastMoveTime: Date
    
    var tiles: [[tile]]
    var spellContexts: [spellContext]=[]
    var winner: player?
    
    var battleStatus: battleStatus
    
    init(tiles: [[tile]]){
        self.tiles=tiles
        self.curGameState=gameState.running
    }
    
    /*moves the turn cycle to the next player in the turn order and runs the function to process that players next turn*/
    func nextTurn(){ //turn management
        guard curGameState == gameState.running else {return}
        currentPlayerIndex = (currentPlayerIndex+1)%turnOrder.count //rotate thru ALL players
        let currentPlayer=turnOrder[currentPlayerIndex]
        //processTurn(for: currentPlayer) //want to put this in a separate file
        //handles +mana, move, cast a spell, and therefore should be built at the end of models
    }
    
    /*calls helper functions for all effects within the spellEffects struct so that they can be applied and/or cancel out existing effects to that player/tile*/
    func applyEffects(){
        for context in spellContexts{
            for effect in context.tileEffects{
                handleEffect(effect: effect, curTile: tile)
            }
        }
    }
    
    /*for any one given spell effect will call helper functions to apply and/or cancel out all elements of that spell effect*/
    func handleEffect(effect: spellEffect, curTile: inout tile){
        if effect.damage > 0 {
            let effectiveDamage = applyDamage(to: &curTile, damage: effect.damage)
            if positionCompare(position1: battleStatus.player1.position, position2: curTile.position)==true {
                battleStatus.player1.health -= effectiveDamage
            }
            else{
                if positionCompare(position1: battleStatus.player2.position, position2: curTile.position)==true {
                    battleStatus.player2.health -= effectiveDamage
                }
            }
        }

        if effect.tickDamage > 0 {
            applyTickDamage(to: &curTile, tickDamage: effect.tickDamage)
        }

        if effect.duration > 1 {
            curTile.effects.append(effect)
        }

        for removeEffect in effect.removeEffects {
            applyRemoveEffects(to: &curTile, effect: removeEffect)
        }

        for chainedEffect in effect.chainedEffects {
            handleEffect(effect: chainedEffect, curTile: &tile)
        }

        if !effect.pathEffects.isEmpty {
            var affectedTiles = [curTile]
            applyPathEffects(to: &affectedTiles, effects: effect.pathEffects)
        }

        if effect.absorbsNextSpell {
            applyAbsorbsNextSpell(to: &curTile)
        }

        if effect.reflectEffect {
            applyReflectEffect(tile: &curTile)
        }

        if let purifyElement = effect.purifyTarget {
            purifyTarget(from: &curTile, elementType: purifyElement.rawValue)
        }

        if effect.restrictVision {
            applyRestrictVision(to: &curTile)
        }

        if effect.immobalized {
            applyImmobilize(to: &curTile)
        }

        if let passiveEffect = effect.passiveEffect, let player = curTile.occupyingPlayer {
            passiveEffect(player)
        }
    }
    
    func applyDamage(to tile: inout tile, damage: Int) -> Int{
        let effectiveDamage=max(0, damage-tile.damageReduction)
        return effectiveDamage //prob want to just apply this directly to the player if occupied
    }
    
    func applyTickDamage(to tile: inout tile, tickDamage: Int){
        tile.tickDamage+=tickDamage
    }
    
    func applyRemoveEffects(to tile: inout tile, effect: String){
        switch effect{
        case "ice": tile.isImmobalized=false
        case "fire": tile.tickDamage=max(0, tile.tickDamage-5)
        case "darkness": tile.restrictVision=false
        default: print("Unknown effect: \(effect)")
        }
    }
    
    func applyPathEffects(to tiles: inout [tile], effects: [spellEffect]){
        for tile in tiles{
            for effect in effects{
                var mutableTile=tile
                handleEffect(effect: spellEffect, tile: &mutableTile)
            }
        }
    }
    
    func applyAbsorbsNextSpell(to tile: inout tile){
        tile.absorbsNextSpell = !tile.absorbsNextSpell
    }
    
    func applyReflectEffect(tile: inout tile){
        tile.reflectEffect = !tile.reflectEffect
    }
    
    func purifyTarget(from tile: inout tile, elementType: String){
        tile.localElementTypes.removeAll {$0==elementType}
    }
    
    func applyRestrictVision(to tile: inout tile){
        tile.restrictVision = !tile.restrictVision
    }
    
    func applyImmobilize(to tile: inout tile){
        tile.isImmobalized = !tile.isImmobalized
    }
    
    /*function to ensure that the tile the player is moving to is within the grid bounds and then updates
     tile struct to show that the old tile is unoccupied and new one is*/
    func movePlayer(player: player, to newTile: tile){
        guard curGameState == gameState.running else {return}
        guard var currentTile=getTile(at: player.position) else {return}
        
        currentTile.isOccupied=false
        player.position=newTile.position
        tiles[newTile.position.x][newTile.position.y].isOccupied=true
    }
    
    /*ensures that any called for position is within the bounds of the grid*/
    func getTile(at position: position) -> tile? {
        guard position.x >= 0, position.x < tiles.count,
              position.y >= 0, position.y < tiles[0].count else { return nil}
        return tiles[position.x][position.y]
    }
    
    /*adds an effect to the tiles spellEffect array*/
    func updateTileEffects(for position: position, with effect: spellEffect){
        guard var targetTile = getTile(at: position) else { return }
        targetTile.effects.append(effect)
        tiles[position.x][position.y] = targetTile
    }
    
    /*removes all effects from a tile*/
    func clearTileEffects(for position: position) {
        guard var targetTile = getTile(at: position) else { return }
        targetTile.effects.removeAll()
        tiles[position.x][position.y] = targetTile
    }
    
    /*checks all possible win conditions against existing battleState*/
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
    
    func positionCompare(position1: position, position2: position) -> Bool{
        if position1.x == position2.x && position1.y == position2.y {return true}
        else {return false}
    }
}
