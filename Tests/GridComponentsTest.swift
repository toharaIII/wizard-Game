import XCTest
@testable import Wizard_Game

final class GridComponentTests: XCTestCase{
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
}
