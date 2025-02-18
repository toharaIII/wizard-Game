//holds spell classes
enum elementType{ //holds all spell class names
    case fire
    case ice
    case teleportation
    case protection
    case dark
}

enum triggerType: Equatable{ //all possible ways in which a casted spell can have its effects triggered
    case immediate
    case delayed(turns: Int)
    case proximity(radius: Int)
    
    static func == (lhs: triggerType, rhs: triggerType) -> Bool {
        switch (lhs, rhs) {
        case (.immediate, .immediate):
            return true
        case let (.delayed(turns1), .delayed(turns2)):
            return turns1 == turns2
        case let (.proximity(radius1), .proximity(radius2)):
            return radius1 == radius2
        default:
            return false
        }
    }
}

indirect enum spellEffectReference{ //used so that spellEffects can stored chain effects without recurisve call
    case single(spellEffect)
    case multiple([spellEffect])
}

/*
 stores all possible variables which can be effected by spell components within the spellLibrary
 */
class spellEffect{
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
    
    //minimal initalizer
    init(type: elementType, tiles: [position]){
        self.type = type
        self.tiles=tiles
    }
    
    //maximum initalizer
    init(type: elementType,
             damage: Int = 0,
             tickDamage: Int = 0,
             tiles: [position],
             duration: Int = 1,
             trigger: triggerType = .immediate,
             removeEffects: [String] = [],
             chainedEffects: [spellEffect] = [],
             passiveEffect: ((player) -> Void)? = nil,
             storedEffect: spellEffectReference? = nil,
             pathEffects: [spellEffect] = [],
             isRandom: Bool = false,
             linkedTile: tile? = nil,
             absorbsNextSpell: Bool = false,
             reflectEffect: Bool = false,
             damageReduction: Int = 0,
             purifyTarget: elementType? = nil,
             restrictVision: Bool = false,
             immobalized: Bool = false) {
            
            self.type = type
            self.damage = damage
            self.tickDamage = tickDamage
            self.tiles = tiles
            self.duration = duration
            self.trigger = trigger
            self.removeEffects = removeEffects
            self.chainedEffects = chainedEffects
            self.passiveEffect = passiveEffect
            self.storedEffect = storedEffect
            self.pathEffects = pathEffects
            self.isRandom = isRandom
            self.linkedTile = linkedTile
            self.absorbsNextSpell = absorbsNextSpell
            self.reflectEffect = reflectEffect
            self.damageReduction = damageReduction
            self.purifyTarget = purifyTarget
            self.restrictVision = restrictVision
            self.immobalized = immobalized
        }
}

class spellLibrary{
    class fire{
        static func ball(tile: position, spreadTiles: [position]? = nil) -> spellEffect{
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
