//holds spell classes
enum elementType{ //holds all spell class names
    case fire
    case ice
    case teleportation
    case protection
    case dark
}

enum triggerType{ //all possible ways in which a casted spell can have its effects triggered
    case immediate
    case delayed(turns: Int)
    case proximity(radius: Int)
}

struct position{ //used to store players position on the grid
    let x: Int
    let y: Int
}

indirect enum spellEffectReference{ //used so that spellEffects can stored chain effects without recurisve call
    case single(spellEffect)
    case multiple([spellEffect])
}

func randomTile() -> position { //creates a position struct to a random position within the bounds of the grid
    let randomX=Int.random(in: 0...2)
    let randomY=Int.random(in: 0...5)
    return position(x: randomX, y: randomY)
}

/*
 creates an efficient path between 2 positions on the grid and returns an array of the positions within said path
 */
func calculatePath(from start: position, to end: position) -> [position]{
    var path: [position] = []
    
    if start.x != end.x{
        let range=start.x<end.x ? Array((start.x...end.x)) : (end.x...start.x).reversed()
        for x in range{
            path.append(position(x: x, y: start.y))
        }
    }
    
    if start.y != end.y{
        let range=start.y < end.y ? Array((start.y...end.y)) : (end.y...start.y).reversed()
        for y in range{
            path.append(position(x: end.x, y: y))
        }
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

/*
 stores all possible variables which can be effected by spell components within the spellLibrary
 */
struct spellEffect{
    let type: elementType
    var damage: Int=0
    var tickDamage: Int=0
    var tiles: [position]
    var duration: Int=1
    var trigger: triggerType = .immediate
    var removeEffects: [String]=[]
    var chainedEffects: [spellEffect]=[]
    var passiveEffect: ((player) -> Void)?
    
    var storedEffect: spellEffectReference?
    
    var pathEffects: [spellEffect]=[]
    var isRandom: Bool=false
    var linkedTile: tile?=nil
    
    var absorbsNextSpell: Bool=false //for wards
    var reflectEffect: Bool=false //for mirror
    var damageReduction: Int=0 //for aegis
    var purifyTarget: elementType?=nil //for purify
    
    var restrictVision: Bool=false
    var immobalized: Bool=false
}

class spellLibrary{
    class fire{
        func ball(tile: position, spreadTiles: [position]? = nil) -> spellEffect{
            return spellEffect(
                type: elementType.fire,
                damage: 50,
                tickDamage: 0,
                tiles: [tile]+(spreadTiles ?? []),
                removeEffects: ["ice", "darkness"]
            )
        }
        
        static func willOWisp(tile: position, duration: Int) -> spellEffect{
            return spellEffect(
                type: elementType.fire,
                damage: 0,
                tickDamage: 5,
                tiles: [tile],
                duration: duration,
                removeEffects: ["ice", "darkness"]
            )
        }
        
        static func kindling(tile: position, turnsToActivate: Int, effects: [spellEffect]) -> spellEffect{
            return spellEffect(
                type: elementType.fire,
                tiles: [tile],
                trigger: triggerType.delayed(turns: turnsToActivate),
                removeEffects: ["ice", "darkness"],
                chainedEffects: effects
            )
        }
    }
    class ice{
        static func icicle(tile: position, spreadTiles: [position]? = nil) -> spellEffect{
            return spellEffect(
                type: elementType.ice,
                damage: 25,
                tiles: [tile]+(spreadTiles ?? []),
                removeEffects:["fire"],
                immobalized: true
            )
        }
        static func hail(tiles: [position], duration: Int) ->spellEffect{
            return spellEffect(
                type: elementType.ice,
                damage: 0,
                tickDamage: 0,
                tiles: tiles,
                duration: duration,
                removeEffects: ["fire"],
                immobalized: true
            )
        }
        static func permafrost(tile: position, turnsToStore: Int) -> spellEffect{
            return spellEffect(
                type: elementType.ice,
                damage: 0,
                tiles: [tile],
                trigger: triggerType.delayed(turns: turnsToStore),
                storedEffect: nil as spellEffectReference? //assigned dynamically in game
            )
        }
    }
    class teleportation{
        static func teleport(from: position, to: position? = nil, isRandom: Bool,
            pathEffects: [spellEffect]=[],
            destinationEffects: [spellEffect]=[]) -> spellEffect{
            let targetTile: position
            if isRandom{
                targetTile=randomTile() //need to make this function
            }
            else{
                targetTile = to ?? from
            }
            let path=calculatePath(from: from, to: targetTile) //need to make this function
            
            return spellEffect(
                type: elementType.teleportation,
                damage: 0,
                tickDamage: 0,
                tiles: path,
                chainedEffects: destinationEffects,
                pathEffects: pathEffects,
                isRandom: isRandom
            )
        }
        static func portal(tile: position, isRandom: Bool, duration: Int, effects: [spellEffect]=[]) -> spellEffect{
            return spellEffect(
                type: elementType.teleportation,
                damage: 0,
                tickDamage: 0,
                tiles: [tile],
                duration: duration,
                pathEffects: effects,
                isRandom: isRandom,
                linkedTile: nil as tile?//portal end destination linked dynamically in game
            )
        }
    }
    class protection{
        static func minorWard(tile: position) -> spellEffect{
            return spellEffect(
                type: elementType.protection,
                damage: 0,
                tiles: [tile],
                absorbsNextSpell: true
            )
        }
        static func majorWard(tile: position, effects:[spellEffect]=[]) -> spellEffect{
            return spellEffect(
                type: elementType.protection,
                damage: 0,
                tiles: [tile],
                chainedEffects: effects,
                absorbsNextSpell: true
            )
        }
        static func aegis(tile: position, damageReduction: Int, effects: [spellEffect]=[]) -> spellEffect{
            return spellEffect(
                type: elementType.protection,
                damage: 0,
                tiles: [tile],
                chainedEffects: effects,
                damageReduction: damageReduction
            )
        }
        static func mirror(tile: position) -> spellEffect{
            return spellEffect(
                type: elementType.protection,
                damage: 0,
                tiles: [tile],
                reflectEffect: true
            )
        }
        static func purify(tile: position, targetClass: elementType) -> spellEffect{
            return spellEffect(
                type: elementType.protection,
                damage: 0,
                tiles: [tile],
                purifyTarget: targetClass
            )
        }
    }
    class dark{
        static func shroud(tiles: [position], duration: Int) -> spellEffect{
            return spellEffect(
                type: elementType.dark,
                damage: 5,
                tickDamage: 5,
                tiles: tiles,
                duration: duration,
                restrictVision: true
            )
        }
    }
}
