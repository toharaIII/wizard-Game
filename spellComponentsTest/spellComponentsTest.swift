import Testing
import Wizard_Game

struct SpellSystemTests {
    @Test func testBasicSpellCreation() {
        let testPosition = position(x: 0, y: 0)
        
        // Test fire spells
        let fireball = spellLibrary.fire.ball(tile: testPosition)
        #expect(fireball.type == .fire)
        #expect(fireball.damage == 50)
        #expect(fireball.tiles.count == 1)
        
        // Test ice spells
        let icicle = spellLibrary.ice.icicle(tile: testPosition)
        #expect(icicle.type == .ice)
        #expect(icicle.damage == 25)
        
        // Test protection spells
        let ward = spellLibrary.protection.minorWard(tile: testPosition)
        #expect(ward.type == .protection)
        #expect(ward.absorbsNextSpell)
    }
    
    @Test func testSpellChaining() {
        let testPosition = position(x: 0, y: 0)
        
        // Create a delayed fire spell that chains into an ice spell
        let iceEffect = spellLibrary.ice.icicle(tile: testPosition)
        let delayedFire = spellLibrary.fire.kindling(
            tile: testPosition,
            turnsToActivate: 2,
            effects: [iceEffect]
        )
        
        #expect(delayedFire.chainedEffects.count == 1)
        if case .delayed(let turns) = delayedFire.trigger {
            #expect(turns == 2)
        }
    }
    
    @Test func testSpellEffects() {
        let testPosition = position(x: 0, y: 0)
        
        // Test Will-o-Wisp duration
        let wisp = spellLibrary.fire.willOWisp(tile: testPosition, duration: 3)
        #expect(wisp.duration == 3)
        #expect(wisp.tickDamage == 5)
        
        // Test Shroud effect stacking
        let shroud = spellLibrary.dark.shroud(tiles: [testPosition], duration: 2)
        #expect(shroud.canStack)
        #expect(shroud.restrictVision)
    }
    
    @Test func testTeleportation() {
        let startPos = position(x: 0, y: 0)
        let endPos = position(x: 5, y: 5)
        
        // Test directed teleport
        let teleport = spellLibrary.teleportation.teleport(
            from: startPos,
            to: endPos,
            isRandom: false
        )
        #expect(!teleport.isRandom)
        
        // Test random teleport
        let randomTeleport = spellLibrary.teleportation.teleport(
            from: startPos,
            to: nil,
            isRandom: true
        )
        #expect(randomTeleport.isRandom)
    }
    
    @Test func testProtectionEffects() {
        let testPosition = position(x: 0, y: 0)
        
        // Test Aegis damage reduction
        let aegis = spellLibrary.protection.aegis(
            tile: testPosition,
            damageReduction: 25,
            effects: []
        )
        #expect(aegis.damageReduction == 25)
        
        // Test Purify targeting
        let purify = spellLibrary.protection.purify(
            tile: testPosition,
            targetClass: .fire
        )
        #expect(purify.purifyTarget == .fire)
    }
    
    @Test func testEffectInteractions() {
        let testPosition = position(x: 0, y: 0)
        
        // Test fire removing ice effects
        let fireball = spellLibrary.fire.ball(tile: testPosition)
        #expect(fireball.removeEffects.contains("ice"))
        
        // Test mirror reflection
        let mirror = spellLibrary.protection.mirror(tile: testPosition)
        #expect(mirror.reflectEffect)
    }
}
