//defines what makes up a spell, references to load data into a templated class for all of the users created spells
struct spell{
    let name: String
    let description: String
    let author: String
    
    typealias spellLogic = (SpellContext) -> [spellEffect]
    let execute: SpellLogic
    
    let manaCost: Int
    
    let sourceCode: String
    let createdAt: Date
    let lastModified: Date
    
    var lastExecutionSuccess: Bool?
    var lastError: String?
}

struct spellContext{
    let casterPosition: position
    let target: position
    let battlefield: [[Tile]]
    
    let playerHealth: Int
    let playerMana: Int
    let turnNumber: Int
    
    let tileEffects: [spellEffect]
}

//just for me to understand wtf im even doing :D
struct ExampleSpells {
    static func fireballBarrage(context: SpellContext) -> [spellEffect] {
        var effects: [spellEffect] = []
        
        // Get all enemies in range
        let targets = context.getTargetsInRadius(
            center: context.casterPosition,
            radius: 3
        )
        
        // Cast a fireball at each target
        for target in targets {
            if context.hasLineOfSight(from: context.casterPosition, to: target) {
                effects.append(spellLibrary.fire.ball(tile: target))
            }
        }
        
        return effects
    }
    
    static func frostNova(context: SpellContext) -> [spellEffect] {
        let effects: [spellEffect] = []
        let centerPos = context.casterPosition
        
        // Create expanding rings of frost
        for radius in 1...3 {
            let ring = context.getTargetsInRadius(center: centerPos, radius: radius)
            effects.append(spellLibrary.ice.icicle(
                tile: centerPos,
                spreadTiles: ring
            ))
        }
        
        return effects
    }
    
    static func teleportTrap(context: SpellContext) -> [spellEffect] {
        // Create a delayed teleport effect that triggers when enemies are nearby
        let trapPos = context.targets[0]  // First selected target position
        
        // Create the base teleport effect
        let teleEffect = spellLibrary.teleportation.teleport(
            from: trapPos,
            isRandom: true,
            pathEffects: [
                spellLibrary.fire.ball(tile: trapPos)
            ]
        )
        
        // Wrap it in a proximity trigger
        return [spellEffect(
            type: .teleportation,
            tiles: [trapPos],
            trigger: .proximity(radius: 1),
            chainedEffects: [teleEffect]
        )]
    }
}
