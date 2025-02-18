import XCTest
@testable import Wizard_Game

final class SpellParserTests: XCTestCase{
    func testFireballSpell() {
        let spellCode = "cast fireball()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Fireball spell should be valid: \(result.errors)")
    }

    func testIcicleSpell() {
        let spellCode = "cast icicle()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Icicle spell should be valid: \(result.errors)")
    }

    func testKindlingDelayedEffect() {
        let spellCode = "cast kindling()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Kindling spell should be valid: \(result.errors)")
    }

    func testTeleportSpell() {
        let spellCode = "cast teleport()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Teleport spell should be valid: \(result.errors)")
    }

    func testMajorWardSpell() {
        let spellCode = "cast major_ward()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Major Ward spell should be valid: \(result.errors)")
    }

    func testDarkShroudSpell() {
        let spellCode = "cast dark_shroud()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Dark Shroud spell should be valid: \(result.errors)")
    }
    
    func testManaCostBasicSpell() {
        let spellCode = "cast fireball()"
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid spell should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 5, "Base mana cost should be 5 for a simple fireball spell.")
    }
    
    func testManaCostWithLoop() {
        let spellCode = """
        for i in 0..<3 {
            cast fireball()
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
            cast fireball()
        }
        """
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid conditional spell should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 2 * 5, "Conditionally cast spells should incur additional cost.")
    }
    
    func testManaCostWithMultipleEffects() {
        let spellCode = """
        cast fireball()
        cast icicle()
        cast dark_shroud()
        """
        let result = SpellParser.parseSpell(spellCode)
        XCTAssertTrue(result.isValid, "Valid multiple spell cast should not return errors: \(result.errors)")
        
        let calculatedMana = ManaCostCalculator.calculateManaCost(for: spellCode)
        XCTAssertEqual(calculatedMana, 5 + 5 + 5, "Casting multiple spells should increase mana cost.")
    }
}
