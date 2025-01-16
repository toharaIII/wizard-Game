import XCTest

class SpellSystemTests: XCTestCase {
    // Test basic spell creation
    func testBasicSpellCreation() {
        let testPosition = position(x: 0, y: 0)
        
        // Test fire spells
        let fireball = spellLibrary.fire.ball(tile: testPosition)
        XCTAssertEqual(fireball.type, .fire)
        XCTAssertEqual(fireball.damage, 50)
        XCTAssertEqual(fireball.tiles.count, 1)
        
        // Test ice spells
        let icicle = spellLibrary.ice.icicle(tile: testPosition)
        XCTAssertEqual(icicle.type, .ice)
        XCTAssertEqual(icicle.damage, 25)
        
        // Test protection spells
        let ward = spellLibrary.protection.minorWard(tile: testPosition)
        XCTAssertEqual(ward.type, .protection)
        XCTAssertTrue(ward.absorbsNextSpell)
    }
    
    // Test spell combinations and chaining
    func testSpellChaining() {
        let testPosition = position(x: 0, y: 0)
        
        // Create a delayed fire spell that chains into an ice spell
        let iceEffect = spellLibrary.ice.icicle(tile: testPosition)
        let delayedFire = spellLibrary.fire.kindling(
            tile: testPosition,
            turnsToActivate: 2,
            effects: [iceEffect]
        )
        
        XCTAssertEqual(delayedFire.chainedEffects.count, 1)
        if case .delayed(let turns) = delayedFire.trigger {
            XCTAssertEqual(turns, 2)
        } else {
            XCTFail("Expected delayed trigger")
        }
    }
    
    // Test spell effects and duration
    func testSpellEffects() {
        let testPosition = position(x: 0, y: 0)
        
        // Test Will-o-Wisp duration
        let wisp = spellLibrary.fire.willOWisp(tile: testPosition, duration: 3)
        XCTAssertEqual(wisp.duration, 3)
        XCTAssertEqual(wisp.tickDamage, 5)
        
        // Test Shroud effect stacking
        let shroud = spellLibrary.dark.shroud(tiles: [testPosition], duration: 2)
        XCTAssertTrue(shroud.canStack)
        XCTAssertTrue(shroud.restrictVision)
    }
    
    // Test teleportation system
    func testTeleportation() {
        let startPos = position(x: 0, y: 0)
        let endPos = position(x: 5, y: 5)
        
        // Test directed teleport
        let teleport = spellLibrary.teleportation.teleport(
            from: startPos,
            to: endPos,
            isRandom: false
        )
        XCTAssertFalse(teleport.isRandom)
        
        // Test random teleport
        let randomTeleport = spellLibrary.teleportation.teleport(
            from: startPos,
            to: nil,
            isRandom: true
        )
        XCTAssertTrue(randomTeleport.isRandom)
    }
    
    // Test protection and status effects
    func testProtectionEffects() {
        let testPosition = position(x: 0, y: 0)
        
        // Test Aegis damage reduction
        let aegis = spellLibrary.protection.aegis(
            tile: testPosition,
            damageReduction: 25,
            effects: []
        )
        XCTAssertEqual(aegis.damageReduction, 25)
        
        // Test Purify targeting
        let purify = spellLibrary.protection.purify(
            tile: testPosition,
            targetClass: .fire
        )
        XCTAssertEqual(purify.purifyTarget, .fire)
    }
    
    // Test effect removal and interactions
    func testEffectInteractions() {
        let testPosition = position(x: 0, y: 0)
        
        // Test fire removing ice effects
        let fireball = spellLibrary.fire.ball(tile: testPosition)
        XCTAssertTrue(fireball.removeEffects.contains("ice"))
        
        // Test mirror reflection
        let mirror = spellLibrary.protection.mirror(tile: testPosition)
        XCTAssertTrue(mirror.reflectEffect)
    }
}
