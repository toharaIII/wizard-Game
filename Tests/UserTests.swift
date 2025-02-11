import XCTest
@testable import Wizard_Game

final class userTests: XCTestCase{
    func testPlayerInitialization() {
            let playerPosition = position(x: 0, y: 0)
            let testPlayer = player(
                userId: UUID(),
                userName: "TestPlayer",
                battleTome: [],
                position: playerPosition
            )
            
            XCTAssertEqual(testPlayer.userName, "TestPlayer")
            XCTAssertEqual(testPlayer.health, 100)
            XCTAssertEqual(testPlayer.mana, 100)
            XCTAssertEqual(testPlayer.spellsCast, 0)
            XCTAssertEqual(testPlayer.damageDealt, 0)
            XCTAssertEqual(testPlayer.damageReduction, 0)
            XCTAssertEqual(testPlayer.position.x, 0)
            XCTAssertEqual(testPlayer.position.y, 0)
            XCTAssertFalse(testPlayer.restrictedVision)
            XCTAssertFalse(testPlayer.isImmobalized)
            XCTAssertTrue(testPlayer.activeEffects.isEmpty)
        }
        
        func testBattleStatusInitialization() {
            let player1 = player(userId: UUID(), userName: "Alice", battleTome: [], position: position(x: 0, y: 0))
            let player2 = player(userId: UUID(), userName: "Bob", battleTome: [], position: position(x: 1, y: 0))
            
            let battle = battleStatus(
                battleId: UUID(),
                startTime: Date(),
                player1: player1,
                player2: player2,
                turnNumber: 1
            )
            
            XCTAssertNotNil(battle.battleId)
            XCTAssertEqual(battle.turnNumber, 1)
            XCTAssertNil(battle.battleState) // Initially nil
            XCTAssertEqual(battle.player1.userName, "Alice")
            XCTAssertEqual(battle.player2.userName, "Bob")
        }
        
        func testUserInitialization() {
            let testUser = User(
                id: UUID(),
                userName: "MageMaster",
                grimore: [],
                battleTome: [],
                activeBattles: [:],
                wins: 10,
                losses: 5,
                spellsCast: 30,
                damageDealt: 500,
                damageTaken: 400,
                rank: rankings.MasterI
            )
            
            XCTAssertEqual(testUser.userName, "MageMaster")
            XCTAssertEqual(testUser.wins, 10)
            XCTAssertEqual(testUser.losses, 5)
            XCTAssertEqual(testUser.spellsCast, 30)
            XCTAssertEqual(testUser.damageDealt, 500)
            XCTAssertEqual(testUser.damageTaken, 400)
            XCTAssertEqual(testUser.rank, rankings.MasterI)
            XCTAssertTrue(testUser.grimoire.isEmpty)
            XCTAssertTrue(testUser.battleTome.isEmpty)
            XCTAssertTrue(testUser.activeBattles.isEmpty)
        }
        
        func testUserBattleTracking() {
            let user = User(id: UUID(), userName: "Sorcerer", grimore: [], battleTome: [], activeBattles: [:], wins: 0, losses: 0, spellsCast: 0, damageDealt: 0, damageTaken: 0, rank: rankings.AdeptIII)
            
            let player1 = player(userId: UUID(), userName: "Player1", battleTome: [], position: position(x: 0, y: 0))
            let player2 = player(userId: UUID(), userName: "Player2", battleTome: [], position: position(x: 1, y: 0))
            let battle = battleStatus(battleId: UUID(), startTime: Date(), player1: player1, player2: player2, turnNumber: 1)
            
            user.activeBattles[battle.battleId] = battle
            
            XCTAssertEqual(user.activeBattles.count, 1)
            XCTAssertEqual(user.activeBattles[battle.battleId]?.turnNumber, 1)
            XCTAssertEqual(user.activeBattles[battle.battleId]?.player1.userName, "Player1")
            XCTAssertEqual(user.activeBattles[battle.battleId]?.player2.userName, "Player2")
        }
}
