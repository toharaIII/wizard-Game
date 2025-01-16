//holds spell classes
enum elementType{
    case fire
    case ice
    case teleportation
    case protection
    case dark
}

enum triggerType{
    case immediate
    case delayed(turns: Int)
    case proximity(radius: Int)
}

struct position{
    let x: Int
    let y: Int
}

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
    
    var storedEffect: spellEffect?
    
    var pathEffects: [spellEffect]=[]
    var isRandom: Bool=false
    var linkedTile: position?=nil
    
    var absorbsNextSpell: Bool=false //for wards
    var reflectEffect: Bool=false //for mirror
    var damageReduction: Int=0 //for aegis
    var purifyTarget: elementType?=nil //for purify
    
    var restrictVision: Bool=false
    var canStack: Bool=false
}

class spellLibrary{
    class fire{
        static func ball(tile: position, spreadTiles: [position]? = nil) -> spellEffect{
            return spellEffect(
                type: .fire,
                damage: 50,
                tickDamage: 0,
                tiles: [tile]+(spreadTiles ?? []),
                removeEffects: ["ice", "darkness"]
            )
        }
        
        static func willOWisp(tile: position, duration: Int) -> spellEffect{
            return spellEffect(
                type: .fire,
                damage: 0,
                tickDamage: 5,
                tiles: [tile],
                duration: duration,
                removeEffects: ["ice", "darkness"]
            )
        }
        
        static func kindling(tile: position, turnsToActivate: Int, effects: [spellEffect]) -> spellEffect{
            return spellEffect(
                type: .fire,
                trigger: .delayed(turns: turnsToActivate),
                tiles: [tile],
                removeEffects: ["ice", "darkness"],
                chainedEffects: effects
            )
        }
    }
    class ice{
        static func icicle(tile: position, spreadTiles: [position]? = nil) -> spellEffect{
            return spellEffect(
                type: .ice,
                damage: 25,
                tiles: [tile]+(spreadTiles ?? []),
                removeEffects:["fire"],
                passiveEffect: {player in player.isImmobalized=true}
            )
        }
        static func hail(tiles: [position], duration: Int) ->spellEffect{
            return spellEffect(
                type: .ice,
                damage: 0,
                tickDamage: 0,
                tiles: tiles,
                duration: duration,
                removeEffects: ["fire"],
                passiveEffect: {player in player.isImmobalized=true}
            )
        }
        static func permafrost(tile: position, turnsToStore: Int) -> spellEffect{
            return spellEffect(
                type: .ice,
                damage: 0,
                tiles: [tile],
                trigger: .delayed(turns: turnsToStore),
                storedEffect: nil //assigned dynamically in game
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
                type: .teleportation,
                damage: 0,
                tickDamage: 0,
                tiles: path,
                pathEffects: pathEffects,
                chainedEffects: destinationEffects,
                isRandom: isRandom
            )
        }
        static func portal(tile: position, isRandom: Bool, duration: Int, effects: [spellEffect]=[]) -> spellEffect{
            return spellEffect(
                type: .teleportation,
                damage: 0,
                tickDamage: 0,
                tiles: [tile],
                duration: duration,
                pathEffects: effects,
                isRandom: isRandom,
                linkedTile: nil //portal end destination linked dynamically in game
            )
        }
    }
    class protection{
        static func minorWard(tile: position) -> spellEffect{
            return spellEffect(
                type: .protection,
                damage: 0,
                tiles: tile,
                absorbsNextSpell: true
            )
        }
        static func majorWard(tile: position, effects:[spellEffect]=[]) -> spellEffect{
            return spellEffect(
                type: .protection,
                damage: 0,
                tiles: tile,
                absorbsNextSpell: true,
                chainedEffects: effects
            )
        }
        static func aegis(tile: position, damageReduction: Int, effects: [spellEffect]=[]) -> spellEffect{
            return spellEffect(
                type: .protection,
                damage: 0,
                tiles: tile,
                damageReduction: damageReduction,
                chainedEffects: effects
            )
        }
        static func mirror(tile: position) -> spellEffect{
            return spellEffect(
                type: .protection,
                damage: 0,
                tiles: [tile],
                reflectEffect: true
            )
        }
        static func purify(tile: position, targetClass: elementType) -> spellEffect{
            return spellEffect(
                type: .protection,
                damage: 0,
                tiles: [tile],
                purifyTarget: targetClass
            )
        }
    }
    class dark{
        static func shroud(tiles: [position], duration: Int) -> spellEffect{
            return spellEffect(
                type: .dark,
                damage: 5,
                tickDamage: 5,
                tiles: tiles,
                duration: duration,
                restrictVision: true,
                canStack: true
            )
        }
    }
}
