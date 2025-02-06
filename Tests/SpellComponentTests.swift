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

}
