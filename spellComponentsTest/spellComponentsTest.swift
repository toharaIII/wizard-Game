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
    
    // Test spell chaining
    func testSpellChaining() {
        let testPosition = position(x: 0, y: 0)
        
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
        
        let wisp = spellLibrary.fire.willOWisp(tile: testPosition, duration: 3)
        XCTAssertEqual(wisp.duration, 3)
        XCTAssertEqual(wisp.tickDamage, 5)
        
        let shroud = spellLibrary.dark.shroud(tiles: [testPosition], duration: 2)
        XCTAssertTrue(shroud.canStack)
        XCTAssertTrue(shroud.restrictVision)
    }
    
    // Test teleportation system
    func testTeleportation() {
        let startPos = position(x: 0, y: 0)
        let endPos = position(x: 5, y: 5)
        
        let teleport = spellLibrary.teleportation.teleport(
            from: startPos,
            to: endPos,
            isRandom: false
        )
        XCTAssertFalse(teleport.isRandom)
        
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
        
        let aegis = spellLibrary.protection.aegis(
            tile: testPosition,
            damageReduction: 25,
            effects: []
        )
        XCTAssertEqual(aegis.damageReduction, 25)
        
        let purify = spellLibrary.protection.purify(
            tile: testPosition,
            targetClass: .fire
        )
        XCTAssertEqual(purify.purifyTarget, .fire)
    }
    
    // Test effect removal and interactions
    func testEffectInteractions() {
        let testPosition = position(x: 0, y: 0)
        
        let fireball = spellLibrary.fire.ball(tile: testPosition)
        XCTAssertTrue(fireball.removeEffects.contains("ice"))
        
        let mirror = spellLibrary.protection.mirror(tile: testPosition)
        XCTAssertTrue(mirror.reflectEffect)
    }
    
    // Test spell execution with spellContext
    func testSpellExecution() {
        let context = spellContext(
            casterPosition: position(x: 0, y: 0),
            target: position(x: 2, y: 2),
            battlefield: [[]], // Simulate an empty battlefield
            playerHealth: 100,
            playerMana: 50,
            turnNumber: 1,
            tileEffects: []
        )
        
        // Test fireball barrage
        let fireballBarrage = ExampleSpells.fireballBarrage(context: context)
        XCTAssertEqual(fireballBarrage.count, 0, "No targets in range should result in no effects.")
        
        // Test frost nova
        let frostNova = ExampleSpells.frostNova(context: context)
        XCTAssertEqual(frostNova.count, 3, "Expected 3 expanding frost nova effects.")
        
        // Test teleport trap
        let teleportTrap = ExampleSpells.teleportTrap(context: context)
        XCTAssertEqual(teleportTrap.count, 1)
        XCTAssertEqual(teleportTrap[0].trigger, .proximity(radius: 1))
    }
    
    // Test error handling in spell execution
    func testSpellExecutionErrors() {
        let context = spellContext(
            casterPosition: position(x: 0, y: 0),
            target: position(x: 2, y: 2),
            battlefield: [[]], // Simulate an empty battlefield
            playerHealth: 100,
            playerMana: 10, // Insufficient mana
            turnNumber: 1,
            tileEffects: []
        )
        
        let insufficientManaSpell = spell(
            name: "High Mana Cost Spell",
            description: "A spell that costs too much mana",
            author: "Test Author",
            execute: ExampleSpells.fireballBarrage,
            manaCost: 50,
            sourceCode: "test source code",
            createdAt: Date(),
            lastModified: Date()
        )
        
        XCTAssertFalse(context.playerMana >= insufficientManaSpell.manaCost, "Player should not have enough mana to cast this spell.")
    }
}
