import XCTest
@testable import Wizard_Game

final class battleStateTests: XCTestCase{
    func testBattleInitialization() {
        let player1 = player(userId: UUID(), userName: "Alice", battleTome: [], position: position(x: 0, y: 0))
        let player2 = player(userId: UUID(), userName: "Bob", battleTome: [], position: position(x: 1, y: 0))
        
        // Create battleStatus without battleState first
        let battle = battleStatus(
            battleId: UUID(),
            startTime: Date(),
            player1: player1,
            player2: player2,
            turnNumber: 1
        )
        
        XCTAssertNotNil(battle.battleId)
        XCTAssertEqual(battle.turnNumber, 1)
        XCTAssertNil(battle.battleState) // Ensure battleState is nil initially
        
        // Create a sample 3x6 grid of tiles (adjust size as needed)
        let grid: [[tile]] = (0..<3).map { x in
            (0..<6).map { y in
                tile(position: position(x: x, y: y))
            }
        }
        
        // Initialize battleState with the existing battleStatus
        let battleStateInstance = battleState(tiles: grid, battleStatus: battle)
        
        // Assign battleState to battleStatus
        battle.battleState = battleStateInstance

        XCTAssertNotNil(battle.battleState) // Ensure batt
        }
        
        func testPlayerTakesDamage() {
            let player = player(userId: UUID(), userName: "Wizard", battleTome: [], position: position(x: 0, y: 0))
            player.health -= 20
            
            XCTAssertEqual(player.health, 80)
        }
        
        func testSpellEffectApplication() {
            let position = position(x: 1, y: 1)
            let effect = spellEffect(type: .fire, damage: 20, tiles: [position])
            
            XCTAssertEqual(effect.type, .fire)
            XCTAssertEqual(effect.damage, 20)
        }
        
        func testTileEffectApplication() {
            var tile = tile(position: position(x: 2, y: 2))
            let effect = spellEffect(type: .ice, tiles: [tile.position], immobalized: true)
            tile.effects.append(effect)
            
            XCTAssertEqual(tile.effects.count, 1)
            XCTAssertTrue(tile.effects[0].immobalized)
        }
        
        func testUserStatisticsTracking() {
            let user = User(id: UUID(), userName: "WizardMaster", grimore: [], battleTome: [], activeBattles: [:], wins: 3, losses: 1, spellsCast: 10, damageDealt: 150, damageTaken: 100, rank: .AdeptIII)
            user.wins += 1
            user.damageDealt += 30
            
            XCTAssertEqual(user.wins, 4)
            XCTAssertEqual(user.damageDealt, 180)
        }
}
