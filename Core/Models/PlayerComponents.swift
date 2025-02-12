class playerSpellLibrary{
    func getPlayerHealth(for player: player, battleStatus: battleStatus) ->Int{
        return player.health
    }
    
    func getPlayerMana(for player: player, battleStatus: battleStatus) ->Int{
        return player.mana
    }
    
    func getTurnNumber(battleStatus: battleStatus) ->Int{
        return battleStatus.battleState!.turnNumber
    }
    
    func checkPlayerRelativePosition(for player: player, battleStatus: battleStatus, relativeX: Int, relativeY: Int) -> Int{
        //return 0 if nothing, returns 1 if spell, returns 2 if player, 3 for both
        let newPosX=player.position.x+relativeX
        let newPosY=player.position.y+relativeY
        let checkTile=battleStatus.battleState!.tiles[newPosX][newPosY]
        
        print("Player Position: \(player.position), Relative Position: (\(relativeX), \(relativeY))")
        print("New Position: (\(newPosX), \(newPosY))")
        print("Tile Occupied: \(checkTile.isOccupied), Tile Effects: \(checkTile.effects)")
        
        var answer=0
        if !checkTile.effects.isEmpty{
            answer+=1
        }
        if checkTile.isOccupied{
            answer+=2
        }
        return answer
    }
    
    func checkTileRelativePosition(for tile: tile, battleStatus: battleStatus, relativeX: Int, relativeY: Int) -> Int{
        let newPosX=tile.position.x+relativeX
        let newPosY=tile.position.y+relativeY
        let checkTile=battleStatus.battleState!.tiles[newPosX][newPosY]
        
        print("tile Position: \(tile.position), Relative Position: (\(relativeX), \(relativeY))")
        print("New Position: (\(newPosX), \(newPosY))")
        print("Tile Occupied: \(checkTile.isOccupied), Tile Effects: \(checkTile.effects)")
        
        var answer=0
        if !checkTile.effects.isEmpty{
            answer+=1
        }
        if checkTile.isOccupied{
            answer+=2
        }
        return answer
    }
    
    func checkEntityAbsolutePosition(battleStatus: battleStatus, absoluteX: Int, absoluteY: Int) ->Int{
        var answer=0
        let checkTile = battleStatus.battleState!.tiles[absoluteX][absoluteY]
        if !checkTile.effects.isEmpty{
            answer+=1
        }
        if checkTile.isOccupied{
            answer+=2
        }

        print("Tile Occupied: \(checkTile.isOccupied), Tile Effects: \(checkTile.effects)")
        
        return answer
    }
    
    private func getCurrentPlayer(battleStatus: battleStatus) -> player{
        let (currentPlayer, otherPlayer)=battleStatus.battleState!.getCurrentPlayers(currentPlayerName: battleStatus.battleState!.turnOrder[battleStatus.battleState!.currentPlayerIndex])!
        return currentPlayer
    }
    
    private func getOtherPlayer(battleStatus: battleStatus) -> player{
        let (currentPlayer, otherPlayer)=battleStatus.battleState!.getCurrentPlayers(currentPlayerName: battleStatus.battleState!.turnOrder[battleStatus.battleState!.currentPlayerIndex])!
        return otherPlayer
    }
}
