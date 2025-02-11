struct position: Equatable{ //used to store players position on the grid
    let x: Int
    let y: Int
    
    static func == (lhs: position, rhs: position) -> Bool {
        return lhs.x==rhs.x && lhs.y == rhs.y
    }
}

func positionCompare(position1: position, position2: position) -> Bool{
    if position1.x == position2.x && position1.y == position2.y {return true}
    else {return false}
}

func randomTile() -> position { //creates a position struct to a random position within the bounds of the grid
    let randomX=Int.random(in: 0...2)
    let randomY=Int.random(in: 0...5)
    return position(x: randomX, y: randomY)
}

func reflectRow(pos: position) -> position{
    let reflectedPosition = position(x:7-pos.x, y:pos.y)
    return reflectedPosition
}

func findRelativePosition(pos: position, dx: Int, dy: Int) -> position?{
    let newX=pos.x+dx
    let newY=pos.y+dy
    if (1...3).contains(newX) && (1...6).contains(newY){
        return position(x:newX, y:newY)
    }
    return nil
}

/*
 creates an efficient path between 2 positions on the grid and returns an array of the positions within said path
 */
func calculatePath(from start: position, to end: position) -> [position] {
    var path: [position] = [start]
    var current = start

    while current.x != end.x || current.y != end.y {
        let nextX = current.x + (current.x < end.x ? 1 : (current.x > end.x ? -1 : 0))
        let nextY = current.y + (current.y < end.y ? 1 : (current.y > end.y ? -1 : 0))
        
        current = position(x: nextX, y: nextY) // Create a new immutable struct
        path.append(current)
    }

    return path
}

struct tile{ //grid is made up of a 3x6 array of these objects
    let position: position
    var isOccupied: Bool=false
    var effects: [spellEffect]=[]
    
    var tickDamage: Int=0
    var absorbsNextSpell: Bool=false
    var reflectEffect: Bool=false
    var damageReduction: Int=0
    var restrictVision: Bool=false
    var isImmobalized: Bool=false
    var localElementTypes: [String]=[]
}
