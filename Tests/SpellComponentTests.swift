import XCTest
@testable import Wizard_Game

final class SpellComponentTests: XCTestCase{
    func testPositionInitialization(){
        let pos=position(x:1, y:2)
        XCTAssertEqual(pos.x, 1)
        XCTAssertEqual(pos.y, 2)
    }
    
    func testRandomTile() {
        let pos = randomTile()
        XCTAssertTrue((0...2).contains(pos.x), "X coordinate out of bounds")
        XCTAssertTrue((0...5).contains(pos.y), "Y coordinate out of bounds")
    }
    
    func testTileInitialization() {
        let pos = position(x: 1, y: 1)
        let tile = tile(position: pos)

        XCTAssertEqual(tile.position.x, 1)
        XCTAssertEqual(tile.position.y, 1)
        XCTAssertFalse(tile.isOccupied)
        XCTAssertEqual(tile.effects.count, 0)
        XCTAssertEqual(tile.tickDamage, 0)
    }
    
    func testSpellEffectInitialization() {
        let pos = position(x: 0, y: 0)
        let spell = spellEffect(type: .fire, tiles: [pos])

        XCTAssertEqual(spell.type, .fire)
        XCTAssertEqual(spell.tiles.count, 1)
        XCTAssertEqual(spell.tiles[0].x, 0)
        XCTAssertEqual(spell.tiles[0].y, 0)
        XCTAssertEqual(spell.damage, 0)
    }

    func testSpellEffectWithDamage() {
        let pos = position(x: 2, y: 3)
        let spell = spellEffect(type: .fire, damage: 50, tiles: [pos])

        XCTAssertEqual(spell.type, .fire)
        XCTAssertEqual(spell.damage, 50)
        XCTAssertEqual(spell.tiles.count, 1)
    }

    func testSpellEffectWithChainedEffects() {
        let pos = position(x: 1, y: 1)
        let subEffect = spellEffect(type: .ice, tiles: [pos], immobalized: true)
        let spell = spellEffect(type: .fire, tiles: [pos], chainedEffects: [subEffect])

        XCTAssertEqual(spell.chainedEffects.count, 1)
        XCTAssertEqual(spell.chainedEffects[0].type, .ice)
        XCTAssertTrue(spell.chainedEffects[0].immobalized)
    }
    
    func testCalculatePathStraightLine() {
        let start = position(x: 0, y: 0)
        let end = position(x: 0, y: 3)
        let path = calculatePath(from: start, to: end)
            
        XCTAssertEqual(path.count, 4)
        XCTAssertEqual(path[0], position(x: 0, y: 0))
        XCTAssertEqual(path[3], position(x: 0, y: 3))
    }
        
    func testCalculatePathDiagonal() {
        let start = position(x: 0, y: 0)
        let end = position(x: 2, y: 2)
        let path = calculatePath(from: start, to: end)
        
        XCTAssertEqual(path.count, 3)
        XCTAssertEqual(path.last, end)
    }

    final class SpellLibraryTests: XCTestCase {
        func testFireBall() {
            let tile = position(x: 2, y: 3)
            let spreadTiles = [position(x: 3, y: 3), position(x: 4, y: 3)]
            let effect = spellLibrary.fire().ball(tile: tile, spreadTiles: spreadTiles)
            
            XCTAssertEqual(effect.type, elementType.fire)
            XCTAssertEqual(effect.damage, 50)
            XCTAssertEqual(effect.tickDamage, 0)
            XCTAssertEqual(effect.tiles, [tile] + spreadTiles)
            XCTAssertEqual(effect.removeEffects, ["ice", "darkness"])
        }
        
        func testFireWillOWisp() {
            let tile = position(x: 1, y: 1)
            let effect = spellLibrary.fire.willOWisp(tile: tile, duration: 3)
            
            XCTAssertEqual(effect.type, elementType.fire)
            XCTAssertEqual(effect.damage, 0)
            XCTAssertEqual(effect.tickDamage, 5)
            XCTAssertEqual(effect.tiles, [tile])
            XCTAssertEqual(effect.duration, 3)
        }
        
        func testFireKindling() {
            let tile = position(x: 5, y: 5)
            let chainedEffect = spellEffect(type: .fire, tiles: [tile])
            let effect = spellLibrary.fire.kindling(tile: tile, turnsToActivate: 2, effects: [chainedEffect])
            
            XCTAssertEqual(effect.type, elementType.fire)
            XCTAssertEqual(effect.tiles, [tile])
            XCTAssertNotNil(effect.trigger)
        }
        
        func testIceIcicle() {
            let tile = position(x: 4, y: 4)
            let effect = spellLibrary.ice.icicle(tile: tile)
            
            XCTAssertEqual(effect.type, elementType.ice)
            XCTAssertEqual(effect.damage, 25)
            XCTAssertTrue(effect.immobalized)
        }
        
        func testIceHail() {
            let tiles = [position(x: 2, y: 2), position(x: 3, y: 3)]
            let effect = spellLibrary.ice.hail(tiles: tiles, duration: 4)
            
            XCTAssertEqual(effect.type, elementType.ice)
            XCTAssertEqual(effect.duration, 4)
        }
        
        func testTeleportationTeleport() {
            let from = position(x: 1, y: 1)
            let to = position(x: 5, y: 5)
            let effect = spellLibrary.teleportation.teleport(from: from, to: to, isRandom: false)
            
            XCTAssertEqual(effect.type, elementType.teleportation)
            XCTAssertFalse(effect.isRandom)
        }
        
        func testProtectionMinorWard() {
            let tile = position(x: 3, y: 3)
            let effect = spellLibrary.protection.minorWard(tile: tile)
            
            XCTAssertEqual(effect.type, elementType.protection)
            XCTAssertTrue(effect.absorbsNextSpell)
        }
        
        func testDarkShroud() {
            let tiles = [position(x: 6, y: 6)]
            let effect = spellLibrary.dark.shroud(tiles: tiles, duration: 3)
            
            XCTAssertEqual(effect.type, elementType.dark)
            XCTAssertTrue(effect.restrictVision)
        }
    }
}
