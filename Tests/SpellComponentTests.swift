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
}
