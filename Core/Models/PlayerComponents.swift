class playerSpellLibrary{
    /*the idea for this class is to give players developing spells access to components about their and the other players status like absolute and relative positon, health mana, along with the currnet turn number so that they could do like a for loop for a set number of turns between when the spell is casted and the effects are applied
     
     
     the biggest challenge for this is that the player for the functions which pass in a player can either be teh caster or the other player, obviously the caster is casting the spell but i want it to work like (getPlayerHealth(me) so i think that the current approach will work fine for the player but how do we default the battle status correctly? do we actually even need the battleStatus parameter or will it just work itself out somehow?
     */
    
    func getPlayerHealth(for player: player, battleStatus: battleStatus) ->Int{
        return player.health
    }
    
    func getPlayerMana(for player: player, battleStatus: battleStatus) ->Int{
        return player.mana
    }
    
    func getTurnNumber(battleStatus: battleStatus) ->Int{
        return battleStatus.battleState!.turnNumber
    }
    
    func checkEntityRelativePositon(for player: player, battleStatus: battleStatus, relativeX: Int, relativeY: Int) -> Int{
        //return 0 if nothing, returns 1 if spell, returns 2 if player
    }
    
    func checkEntityAbsolutePosition(battleStatus: battleStatus, absoluteX: Int, absoluteY: Int) ->Int{
        
    }
    
    private func getCurrentPlayer(battleStatus: battleStatus) -> player{
        
    }
    
    private func getOtherPlayer(battleStatus: battleStatus) -> player{
        
    }
}
