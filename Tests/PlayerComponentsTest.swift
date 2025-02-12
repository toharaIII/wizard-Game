import XCTest
@testable import Wizard_Game

final class PlayerComponentTests: XCTestCase{
    var spellLibrary: playerSpellLibrary!
        var player1: player!
        var player2: player!
        var battleState: battleState!
        var battleStatus: battleStatus!
        var tiles: [[tile]]!

        override func setUp() {
            super.setUp()
            
            // Initialize spell library
            spellLibrary = playerSpellLibrary()
            
            // Create a 3x3 grid of tiles for testing
            tiles = (0..<3).map { x in
                (0..<3).map { y in tile(position: position(x: x, y: y), isOccupied: false, effects: []) }
            }
            
            // Initialize players
            player1 = player(
                userId: UUID(),
                userName: "Player1",
                battleTome: [],
                position: position(x: 1, y: 1)
            )
            
            player2 = player(
                userId: UUID(),
                userName: "Player2",
                battleTome: [],
                position: position(x: 2, y: 2)
            )
            
            // Initialize battle status
            battleStatus = Wizard_Game.battleStatus(
                battleId: UUID(),
                startTime: Date(),
                player1: player1,
                player2: player2,
                turnNumber: 5
            )
            
            // Initialize battle state
            battleState = Wizard_Game.battleState(tiles: tiles, battleStatus: battleStatus)
            
            // Assign battleState to battleStatus
            battleStatus.battleState = battleState
        }
        
        func testGetPlayerHealth() {
            XCTAssertEqual(spellLibrary.getPlayerHealth(for: player1, battleStatus: battleStatus), 100)
            XCTAssertEqual(spellLibrary.getPlayerHealth(for: player2, battleStatus: battleStatus), 100) // Default health is 100
        }
        
        func testGetPlayerMana() {
            XCTAssertEqual(spellLibrary.getPlayerMana(for: player1, battleStatus: battleStatus), 100) // Default mana is 100
            XCTAssertEqual(spellLibrary.getPlayerMana(for: player2, battleStatus: battleStatus), 100)
        }
        
        func testGetTurnNumber() {
            XCTAssertEqual(spellLibrary.getTurnNumber(battleStatus: battleStatus), 0)
        }
        
        func testCheckPlayerRelativePosition() {
            // Place player2 adjacent to player1
            player2.position = position(x: 2, y: 1)
            tiles[2][1].isOccupied = true

            XCTAssertEqual(spellLibrary.checkPlayerRelativePosition(for: player1, battleStatus: battleStatus, relativeX: 1, relativeY: 0), 2) // Player is present
            XCTAssertEqual(spellLibrary.checkPlayerRelativePosition(for: player1, battleStatus: battleStatus, relativeX: 0, relativeY: 1), 0) // Empty tile
        }
        
        func testCheckTileRelativePosition() {
            // Place an effect on a tile
            let firestorm = spellEffect(
                type: .fire,
                tiles: [position(x: 1, y: 1), position(x: 2, y: 1), position(x: 1, y: 2)]
            )
            firestorm.tickDamage = 5
            firestorm.duration = 3
            firestorm.trigger = .delayed(turns: 1)
            
            tiles[2][1].effects.append(firestorm)
            XCTAssertEqual(spellLibrary.checkTileRelativePosition(for: tiles[1][1], battleStatus: battleStatus, relativeX: 1, relativeY: 1), 1) // Effect present
            
            // Mark a tile as occupied
            tiles[0][1].isOccupied = true
            XCTAssertEqual(spellLibrary.checkTileRelativePosition(for: tiles[0][0], battleStatus: battleStatus, relativeX: 0, relativeY: 1), 2) // Occupied
        }
        
        func testCheckEntityAbsolutePosition() {
            // Place effect and occupation
            let frostTrap = spellEffect(
                type: .ice,
                tiles: [position(x: 3, y: 2)]
            )
            frostTrap.immobalized = true
            frostTrap.trigger = .proximity(radius: 1)
            
            tiles[3][2].effects.append(frostTrap)
            tiles[3][2].isOccupied = true
            XCTAssertEqual(spellLibrary.checkEntityAbsolutePosition(battleStatus: battleStatus, absoluteX: 3, absoluteY: 2), 3) // Both effect and player present
        }
}
