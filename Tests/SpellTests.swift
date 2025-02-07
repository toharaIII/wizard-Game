import XCTest
@testable import Wizard_Game

final class SpellTests: XCTestCase{
    func testSpellInitialization() {
            let testEffect = spellEffect(type: .fire, tiles: [position(x: 0, y: 0)])
            let testSpell = spell(
                name: "Fireball",
                description: "A powerful fire spell.",
                author: "Archmage",
                effect: testEffect,
                secondaryTile: false,
                manaCost: 50,
                sourceCode: "cast fireball()"
            )
            
            XCTAssertEqual(testSpell.name, "Fireball")
            XCTAssertEqual(testSpell.description, "A powerful fire spell.")
            XCTAssertEqual(testSpell.author, "Archmage")
            XCTAssertEqual(testSpell.manaCost, 50)
            XCTAssertEqual(testSpell.sourceCode, "cast fireball()")
            XCTAssertNotNil(testSpell.createdAt)
            XCTAssertNotNil(testSpell.lastModified)
        }
        
        func testSpellExecutionErrorHandling() {
            var testSpell = spell(
                name: "many icicles",
                description: "hella ice.",
                author: "Ice Storm",
                effect: spellEffect(type: .ice, tiles: [position(x: 1, y: 1)]),
                secondaryTile: false,
                manaCost: 75,
                sourceCode: "cast icicles()"
            )
            
            testSpell.lastExecutionSuccess = false
            testSpell.lastError = "Insufficient mana"
            
            XCTAssertFalse(testSpell.lastExecutionSuccess ?? true)
            XCTAssertEqual(testSpell.lastError, "Insufficient mana")
        }
}
