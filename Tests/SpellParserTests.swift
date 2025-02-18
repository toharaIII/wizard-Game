import XCTest
@testable import Wizard_Game

final class SpellParserTests: XCTestCase{
    func testFireballSpell() {
        let spellCode = "fireball(tile: otherplayer.getEntityAbsolutePosition())"
        let result = SpellParser.parseSpell(spellCode)
        print("parsing spell: ", spellCode)
        print("result: ", result)
        XCTAssertTrue(result.isValid, "Fireball spell should be valid: \(result.errors)")
    }

    func testIcicleSpell() {
        let spellCode = "icicle(tile: otherplayer.getEntityAbsolutePosition())"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Icicle spell should be valid: \(result.errors)")
    }

    func testKindlingDelayedEffect() {
        let spellCode = "kindling(tile: otherplayer.getEntityAbsolutePosition(), turnsToActivate: 2, effects: [])"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Kindling spell should be valid: \(result.errors)")
    }

    func testTeleportSpell() {
        let spellCode = "teleport(from: me.getEntityAbsolutePosition(), to: otherplayer.getEntityAbsolutePosition(), isRandom: false)"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Teleport spell should be valid: \(result.errors)")
    }

    func testMajorWardSpell() {
        let spellCode = "majorWard(tile: me.getEntityAbsolutePosition())"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Major Ward spell should be valid: \(result.errors)")
    }

    func testDarkShroudSpell() {
        let spellCode = "shroud(tiles: [otherplayer.getEntityAbsolutePosition()], duration: 3)"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Dark Shroud spell should be valid: \(result.errors)")
    }
    
    func testManaCostBasicSpell() {
        let spellCode = "fire.ball(tile: otherplayer.getEntityAbsolutePosition())"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid spell should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 5, "Base mana cost should be 5 for a simple fireball spell.")
    }
    
    func testManaCostWithLoop() {
        let spellCode = """
        for i in 0..<3 {
            fire.ball(tile: otherplayer.getEntityAbsolutePosition())
        }
        """
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid spell with loop should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 2 * (5 + 5 + 5), "Looped fireball should have a higher mana cost due to repetition.")
    }
    
    func testManaCostWithNesting() {
        let spellCode = """
        if otherplayer.getPlayerHealth() < 50 {
            fire.ball(tile: otherplayer.getEntityAbsolutePosition())
        }
        """
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid conditional spell should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 2 * 5, "Conditionally cast spells should incur additional cost.")
    }
    
    func testManaCostWithMultipleEffects() {
        let spellCode = """
        fire.ball(tile: otherplayer.getEntityAbsolutePosition())
        ice.icicle(tile: otherplayer.getEntityAbsolutePosition())
        dark.shroud(tiles: [otherplayer.getEntityAbsolutePosition()], duration: 3)
        """
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid multiple spell cast should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 5 + 5 + 5, "Casting multiple spells should increase mana cost.")
    }
}
