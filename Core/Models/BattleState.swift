//keeps track of occurances during a battle
import Foundation

enum gameState { //all possible states a battle can be in
    case running
    case gameOver
}

enum spellTarget{
    case none
    case currentPlayer
    case otherPlayer
}

struct turnContext{
    let currentPlayer: player
    let otherPlayer: player
    let selectSpell: spell
    var primaryTile: tile
    var secondaryTile: tile?
}

enum VictoryCondition{
    case playerDefeated
    case timeOut
}

struct victoryResult{
    let winner: player
    let reason: VictoryCondition
}

/*
designed to be a battle manager and hold immediately necessary data for all players
holds all players in turn order, all spell contexts of all tiles, functions to be applied to players or tiles along with those to progress the battle such as advancing turns and checking win conditions
*/
class battleState{
    var battleStatus: battleStatus
    
    var curGameState: gameState
    var turnOrder: [String]=[]
    var turnNumber:Int=0
    var currentPlayerIndex: Int=0
    var lastMoveTime: Date
    
    var tiles: [[tile]]
    var winner: player?
    
    init(tiles: [[tile]], battleStatus: battleStatus){
        self.tiles=tiles
        self.battleStatus=battleStatus
        self.curGameState=gameState.running
        self.turnOrder=[battleStatus.player1.userName, battleStatus.player2.userName].shuffled()
        self.lastMoveTime=Date()
    }
    
    func processTurn(currentPlayer: player){
        guard curGameState == gameState.running else {return}
        
        turnNumber+=1
        
        guard let (currentPlayer, otherPlayer)=getCurrentPlayers(currentPlayerName: turnOrder[currentPlayerIndex]) else {return}
        let players=(currentPlayer, otherPlayer)
        
        players.0.mana+=20
        if let newTile=getMove(for: players.0){
            movePlayer(player: players.0, to: newTile)
        }
        
        guard let selectedSpell=getSpell(for: players.0) else{
            print("No valid spell selected")
            return
        }
        
        players.0.spellsCast+=1
        let primaryTile=selectTile(for: players.0)
        
        var context=turnContext(
            currentPlayer: players.0,
            otherPlayer: players.1,
            selectSpell: selectedSpell,
            primaryTile: primaryTile,
            secondaryTile: selectedSpell.secondaryTile ? selectOptionalTile(for: players.0) : nil
            )
        
        processSpell(context: &context)
        
        checkVictory(currentPlayer: players.0, otherPlayer: players.1)
        if curGameState == gameState.running{ //if no victory condition has been met than begin a new turn with the next player
            currentPlayerIndex = (currentPlayerIndex+1)%turnOrder.count
            if battleStatus.player1.userName==turnOrder[currentPlayerIndex]{processTurn(currentPlayer: battleStatus.player1)}
            else {processTurn(currentPlayer: battleStatus.player2)}
        }
    }
    
    func getCurrentPlayers(currentPlayerName: String) -> (player, player)?{
        if battleStatus.player1.userName==currentPlayerName{
            return (battleStatus.player1, battleStatus.player2)
        } else if battleStatus.player2.userName==currentPlayerName{
            return (battleStatus.player2, battleStatus.player1)
        } else{return nil}
    }
    
    func movePlayer(player: player, to newTile: tile){
        guard curGameState == gameState.running else {return}
        guard var currentTile=getTile(at: player.position) else {return}
        
        currentTile.isOccupied=false
        player.position=newTile.position
        tiles[newTile.position.x][newTile.position.y].isOccupied=true
    }
    
    private func getSpellTarget(primaryTile: tile, currentPlayer: player, otherPlayer: player, secondaryTile: tile? = nil) -> spellTarget{
        if positionCompare(position1: primaryTile.position, position2: currentPlayer.position)==true{
            return spellTarget.currentPlayer
        }
        if positionCompare(position1: primaryTile.position, position2: otherPlayer.position)==true{
            return spellTarget.otherPlayer
        } else{return spellTarget.none}
    }
    
    private func processSpell(context: inout turnContext){
        let target=getSpellTarget(primaryTile: context.primaryTile,
                                  currentPlayer: context.currentPlayer,
                                  otherPlayer: context.otherPlayer)
        switch target{
        case spellTarget.currentPlayer:
            applyEffects(spell: context.selectSpell,
                         caster: context.currentPlayer,
                         primaryTile: &context.primaryTile,
                         secondaryTile: context.secondaryTile,
                         effectedPlayer: context.currentPlayer)
        case spellTarget.otherPlayer:
            applyEffects(spell: context.selectSpell,
                         caster: context.currentPlayer,
                         primaryTile: &context.primaryTile,
                         secondaryTile: context.secondaryTile,
                         effectedPlayer: context.otherPlayer)
        case spellTarget.none:
            applyEffects(spell: context.selectSpell,
                         caster: context.currentPlayer,
                         primaryTile: &context.primaryTile,
                         secondaryTile: context.secondaryTile)
        }
    }
    
    /*calls helper functions for all effects within the spellEffects struct so that they can be applied and/or cancel out existing effects to that player/tile*/
    func applyEffects(spell: spell, caster: player, primaryTile: inout tile, secondaryTile: tile? = nil, effectedPlayer: player? = nil){
        let effect=spell.effect
        caster.mana-=spell.manaCost
        
        if let secTile = secondaryTile { //creates mutable version of secondaryTile
            handleEffect(effect: effect, curTile: &primaryTile, casterPosition: caster.position, secondaryTile: secTile)
        } else{
            handleEffect(effect: effect, curTile: &primaryTile, casterPosition: caster.position)
        }
        
        if let targetPlayer = effectedPlayer {
            handleEffectToPlayer(effect: effect, target: targetPlayer, caster: caster, tile: &primaryTile)
        }
    }
    
    func handleEffectToPlayer(effect: spellEffect, target: player, caster: player, tile: inout tile){
        target.health-=max(0, effect.damage-target.damageReduction)
        caster.damageDealt+=max(0, effect.damage-target.damageReduction)
        if tile.tickDamage>0{
            target.health-=max(0, tile.tickDamage-target.damageReduction)
            caster.damageDealt+=max(0,tile.tickDamage-target.damageReduction)
        }
        if tile.restrictVision==true{
            target.restrictedVision=true
        }
        if tile.isImmobalized==true{
            target.isImmobalized=true
        }
        
    }
    
    /*for any one given spell effect will call helper functions to apply and/or cancel out all elements of that spell effect*/
    func handleEffect(effect: spellEffect, curTile: inout tile, casterPosition: position, secondaryTile: tile? = nil){
        if effect.tickDamage > 0 {
            curTile.tickDamage+=effect.tickDamage
        }

        if effect.duration > 1 { //what to change this approach but not sure to what
            curTile.effects.append(effect)
        }

        for removeEffect in effect.removeEffects {
            applyRemoveEffects(to: &curTile, effect: removeEffect)
        }

        for chainedEffect in effect.chainedEffects {
            handleEffect(effect: chainedEffect, curTile: &curTile, casterPosition: casterPosition)
        }

        if !effect.pathEffects.isEmpty { //what to edit this so that it uses output from calculate path
            let pathPositions=calculatePath(from: casterPosition, to: curTile.position)
            var affectedTiles: [tile]=[]
            
            for pos in pathPositions{
                if let tile=getTile(at: pos){
                    affectedTiles.append(tile)
                }
            }
            
            applyPathEffects(to: &affectedTiles, effects: effect.pathEffects, casterPosition: casterPosition)
        }

        if effect.absorbsNextSpell {
            curTile.absorbsNextSpell = true
        }

        if effect.reflectEffect {
            curTile.reflectEffect = true
        }

        if effect.restrictVision {
            curTile.restrictVision=true
        }

        if effect.immobalized {
            curTile.isImmobalized=true
        }
    }
    
    func applyRemoveEffects(to tile: inout tile, effect: String){
        switch effect{
        case "ice": tile.isImmobalized=false
        case "fire": tile.tickDamage=max(0, tile.tickDamage-5)
        case "darkness": tile.restrictVision=false
        default: print("Unknown effect: \(effect)")
        }
    }
    
    func applyPathEffects(to tiles: inout [tile], effects: [spellEffect], casterPosition: position){
        for tile in tiles{
            for effect in effects{
                var mutableTile=tile
                handleEffect(effect: effect, curTile: &mutableTile, casterPosition: casterPosition)
            }
        }
    }
    
    func purifyTarget(from tile: inout tile, elementType: String){
        tile.localElementTypes.removeAll {$0==elementType}
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
    func checkVictory(currentPlayer: player, otherPlayer: player){
        if let result=checkHealthDefeat(currentPlayer: currentPlayer, otherPlayer: otherPlayer){
            endGame(result)
        }
        if let result=checkTimeOut(lastMoveTime: lastMoveTime, currentPlayer: currentPlayer, otherPlayer: otherPlayer){
            endGame(result)
        }
    }
    
    private func checkHealthDefeat(currentPlayer: player, otherPlayer: player) -> victoryResult?{
        if currentPlayer.health<=0{
            return victoryResult(winner: otherPlayer, reason: VictoryCondition.playerDefeated)
        }
        if otherPlayer.health<=0{
            return victoryResult(winner: currentPlayer, reason: VictoryCondition.playerDefeated)
        }
        return nil
    }
    
    private func checkTimeOut(lastMoveTime: Date, currentPlayer: player, otherPlayer: player) -> victoryResult?{
        let timeElapsed=Date().timeIntervalSince(lastMoveTime)
        let timeOutLimit: TimeInterval=24*60*60
        if timeElapsed>timeOutLimit{
            return victoryResult(winner: otherPlayer, reason: VictoryCondition.timeOut)
        }
        return nil
    }
    
    private func endGame(_ result: victoryResult){
        curGameState=gameState.gameOver
        winner=result.winner
        
        let player1 = battleStatus.player1
        let player2 = battleStatus.player2
        
        let winningPlayer=result.winner
        let losingPlayer=(winningPlayer.userId==player1.userId) ? player2 : player1
        
        if let winnerBattle=getUserActiveBattle(userId: winningPlayer.userId){
            let winnerUser=getUser(userId: winningPlayer.userId)
            winnerUser.wins+=1
            winnerUser.spellsCast+=winnerBattle.spellsCast
            winnerUser.damageDealt+=winnerBattle.damageDealt
            let loserBattle=(winnerBattle.userId == player1.userId) ? player2 : player1
            winnerUser.damageTaken+=loserBattle.damageDealt
        }
        
        if let loserBattle=getUserActiveBattle(userId: losingPlayer.userId) {
                let loserUser=getUser(userId: losingPlayer.userId)
                loserUser.losses+=1
                loserUser.spellsCast+=loserBattle.spellsCast
                loserUser.damageDealt+=loserBattle.damageDealt
                let winnerBattle=(loserBattle.userId == player1.userId) ? player2 : player1
                loserUser.damageTaken+=winnerBattle.damageDealt
        }
        
        removeActiveBattle(battleId: battleStatus.battleId)
    }
    
    private func getUserActiveBattle(userId: UUID) -> player?{
        let user=getUser(userId: userId)
        return user.activeBattles[battleStatus.battleId]?.player1.userId == userId ? battleStatus.player1 : battleStatus.player2
    }
    
    private func removeActiveBattle(battleId: UUID){
        let player1User=getUser(userId: battleStatus.player1.userId)
        let player2User=getUser(userId: battleStatus.player2.userId)
        
        player1User.activeBattles.removeValue(forKey: battleId)
        player2User.activeBattles.removeValue(forKey: battleId)
    }
    
    //IM NOT SURE WE WANT THESE HERE, JUST STUB BUILDS FOR TESTING
    func getMove(for player: player) -> tile? {
        print("getMove called - returning nil as stub")
        return nil  // No movement by default
    }

    func getSpell(for player: player) -> spell? {
        print("getSpell called - returning a stub spell")
        return nil
    }

    func selectTile(for player: player) -> tile {
        print("selectTile called - returning a default tile")
        let defaultPosition=position(x:0, y:0)
        return tile(position: defaultPosition)
    }

    func selectOptionalTile(for player: player) -> tile? {
        print("selectOptionalTile called - returning nil as stub")
        return nil  // No optional tile by default
    }
    
    private func getUser(userId: UUID) -> User{
        //pulls the user class for a given player via their Id from the larger user database
        //needs to be build out alongside user database API
        fatalError("Implimentation needed: retrieve User object for userId: \(userId)")
    }
}
