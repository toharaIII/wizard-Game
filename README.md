# wizard-Game
game about programming spells and using them to fight in turn based combat against other players, iphone launch first

general plan:
will liekly be done primarily in swift, cant use big computer can only use laptop :(
will need to be done in swift
understand new iOS and xocde concepts such as but not limited to:
  creating new projects
  interface builder
  debugging tools and simulators
  niews and view controllers
  navigation controllers, tab bar controllers, etc UI elements
  model view controller design pattern
  spritekit
  scenekit

game conceptualization:
core gameplay loop:
  1. build spells:
     each player will have a grimoire, a book which can hold 10 or so (that number is flexible) of spells
     there will likely be a few generic spells given to the player base at the start of their time with the game, ideally these spells will highly the possibilities of the spell creation engine
      the game will have a custom coding language which will at least make use of things like variable declaration and initialization, along with if-then blocks for reactive spells, I would like to put in things like iteratiors but those may break the game if unchecked
     spells will have different elements that they can make use of for damaging, inflicting status, and/or reduction/enchancement of player/enemy wizard stats/status similar to move pool in pokemon
     spell language creation should be a reasonable challenge with the real difficulty being individual spell balancing
      - unsure if this should be done via limiting number of characters/blocks in a given spell, limiting big O complexity, limiting number of comparisons / iteraions? leaning on that last one as must likely path


  CURRENT SPELL BALANCING APPROACH:
    each player has can write as many spells as they like which are all stored in their grimoire, but they can only bring ten spells to a battle in their battle tome
    through out a game each players battle tome is visible to the other player
    each turn has the following loop: mana recovery, move player wizard(or pass), select spell and cast(or pass)
    each player starts with X mana
    to cast a particular spell costs Y mana, the amount of mana it costs is determined from the Big O complexity of the spell, in the spell creation menu players can either see Big O directly or the mana cost and can switch between them
    there will be various classes of magic, perhaps: fire, ice, rock, dark, teleportation, restoration, enchanting (buffing/debuffing), each of these will have a class (i.e. public, private functions etc) which will have characteristics like initial damage, tick damage (for damage for turns after casting), etc 
    along with availible functions, so for fire think fire.ball, .wall, .blast, .will-o-wisp, etc each with various input parameters
    each classes functions, variables and perhaps datastructures will obviously be viewable for players and hopefully highlighted in the default spells given at the start of the game
    if done right the mana system will balance complexity, reactivity, power, predictability, etc thus not stiflying players abilites to go crazy with the ingame code language while also not breaking the experience for novice coding players, i.e. preventing something like .kill(other player) etc
    

     
  2. battle against other warlocks
    at the start of a battle players will be able to view each other grimoires to get a sense of what 
    handled similar to polytopia in that the game is turned based with each player having 24 hours to take their turn or forfeit the game
     the game will have each players wizard avatar on a 3x3 grid of spaces, each turn a player can move their wizard to any adacent space and cast a spell onto a space either on their grid or the other players
     each wizard avatar has 100 health and once that health is gone they lose the game

additional features (immediate):
  each player has a searchable page where you can add them as a friend, see their friends, and see their grimoire

additional features (far future):
  players can create schools of wizards, similar to clans in clash of clans, these schools can then compete against each other in tournments or direct head to head battles, players can ahead of their own battle choose to give some of their initial mana pool to other players in their school, meanging that they would start with less than X mana but that other player would start with equally more
  players will have stats and perhaps even rankings for those who are the most competitive
  customizable wizards for plays to show off, this would also allow for in game purchases
  
