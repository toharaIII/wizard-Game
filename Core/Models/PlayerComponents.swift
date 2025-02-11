class playerSpellLibrary{
    /*the idea for this class is to give players developing spells access to components about their and the other players status like absolute and relative positon, health and mana*/
    
    func getPlayerHealth(for player: player, battleStatus: battleStatus) ->Int{
        
    }
    
    func getPlayerMana(for player: player, battleStatus: battleStatus) ->Int{
        
    }
    
    func getTurnNumber(battleStatus: battleStatus) ->Int{
        
    }
    
    func getEntityRelativePositon(for player: player, battleStatus: battleStatus, relativeX: Int, relativeY: Int) -> Int{
        //return 0 if nothing, returns 1 if spell, returns 2 if player
    }
    
    func getEntityAbsolutePosition(for player: player, battleStatus: battleStatus, absoluteX: Int, absoluteY: Int) ->Int{
        
    }
    
    private func getCurrentPlayer(battleStatus: battleStatus) -> player{
        
    }
    
    private func getOtherPlayer(battleStatus: battleStatus) -> player{
        
    }
}
