extends Node

signal day_randomized
enum MissionType {COMBAT, DELIVERY}
var mission_type = MissionType.DELIVERY # This will change per day ?
var customer_name: String = ""
var customer_requirements: Array[String] = []
var required_magic = MagicElement.Type.WATER  # set per day
var equipped_items = []
var equipped_stats: Array[String] = [] # What the player equipped
var day_results = {
  "dressup": {
    "outfit": []  # list of what they equipped
  },
  "blacksmith": {
    "passed": false,
    "choice": null
  },
  "typing": {
    "passed": false,
    "choice": null
  }
}
var minigames_completed = {
  "dressup": false,
  "blacksmith": false,
  "typing": false
}
signal day_complete

func randomize_day():
  randomize_character()
  var magic_types = MagicElement.Type.values()
  required_magic = magic_types[randi() % magic_types.size()]
  emit_signal("day_randomized")

  var req_keys = STAT_GROUPS.keys()
  req_keys.shuffle()
  customer_requirements = Array(req_keys.slice(0, 2), TYPE_STRING, "", null)

func _ready():
  randomize()
  randomize_day()
  minigames_completed["blacksmith"] = true # remove when blacksmith added


func is_game_complete(game: String) -> bool:
  if game in minigames_completed:
    return minigames_completed[game]
  return false


func _on_magic_game_complete(magic_type: String, success: bool) -> void:
  day_results["typing"]["passed"] = success
  day_results["typing"]["choice"] = magic_type
  complete_minigame("typing")


func complete_minigame(game_name: String):
  print("complete_minigame called with: ", game_name)
  minigames_completed[game_name] = true
  for game in minigames_completed:
    print(game, ": ", minigames_completed[game])
    if not minigames_completed[game]:
      return
  print("Day complete!")
  emit_signal("day_complete") #trigger the newspaper

func check_day_complete():
  for game in minigames_completed:
    if not minigames_completed[game]:
      return
  emit_signal("day_complete") #trigger the newspaper

const CHARACTERS = [
  {"name": "Elaria", "sprite": preload("res://Art for Shop Game/Characters/female2.png")},
  {"name": "Asema", "sprite": preload("res://Art for Shop Game/Characters/male1.png")},
  ]
var current_character = CHARACTERS[0]

func randomize_character():
  current_character = CHARACTERS[randi() % CHARACTERS.size()]
  customer_name = current_character.name

const PLACE_NAMES = {
  "+Fire Resistance": ["the Volcanic Valley", "the Ember Wastes"],
  "+Poison Resistance": ["the Poisonous Prison", "the Toxic Temple"],
  "+Cold Resistance": ["the Terrible Tundra", "the Freezing Fairway"],
  "+Electric Resistance": ["the Magnetic Mountains", "the Ligtning Fields"],
  "+Wind Resistance": ["the Breezy Battleground", "the Gusty Graveyard", "the Sweltering Sanctum"],
  "+Water Resistance": ["the Sunken Ruins", "the Drowned Den", "the Waterlogged Warzone"],
  }

const DIALOGUE_TEMPLATES = [
  "Hello, Shopkeeper. I'm headed off on an adventure to somewhere that is {req0}, and my armour also needs to deal with {req1} conditions. I'll be travelling {magic}.",
  "Dear Shopkeeper, I am in need of some armour to protect me from somewhere {req0}. Oh, and also protect me from {req1} dangers. I will be going {magic}.",
  "Well met, Shopkeeper. I require some of your finest armour to protect me from someplace {req0} and also be properly equipped for {req1} conditions. My journey sends me {magic}."]

# The synonym groups word is treated as same stat
const STAT_GROUPS = {
  "+Fire Resistance": ["volcanic", "hot", "desert", "boiling", "burning", "blistering", "sweltering"],
  "+Poison Resistance": ["poisonous", "toxic", "venomous", "noxious", "infected"],
  "+Cold Resistance": ["icy", "arctic", "tundra", "freezing", "chilly", "frigid"],
  "+Electric Resistance": ["electrified", "charged", "electrostatic", "energized"],
  "+Wind Resistance": ["windy", "breezy", "gusty"],
  "+Water Resistance": ["wet", "underwater", "sodden", "damp", "waterlogged", "marshy"],
  }

const MAGIC_DESCRIPTIONS = {
  MagicElement.Type.WATER: ["underwater", "through a flooded river", "through the deep sea"],
  MagicElement.Type.MEND: ["over a broken bridge", "using a half-damaged ship", "riding a barely functioning wagon"],
  MagicElement.Type.HEAL: ["a sickly village", "the unwell", "broken bones"],
  MagicElement.Type.FLIGHT: ["high in the mountains", "across a great chasm", "over a huge canyon"]
}
func get_customer_dialogue() -> String:
    var keys = STAT_GROUPS.keys()
    keys.shuffle()
    var word1 = STAT_GROUPS[keys[0]][randi() % STAT_GROUPS[keys[0]].size()]
    var word2 = STAT_GROUPS[keys[1]][randi() % STAT_GROUPS[keys[1]].size()]

    var magic_hint = MAGIC_DESCRIPTIONS[required_magic][randi() % MAGIC_DESCRIPTIONS[required_magic].size()]

    var template = DIALOGUE_TEMPLATES[randi() % DIALOGUE_TEMPLATES.size()]
    return template.replace("{req0}", word1).replace("{req1}", word2).replace("{magic}", magic_hint)

func get_place() -> String:
    if not customer_requirements.is_empty():
        var places = PLACE_NAMES.get(customer_requirements[0], ["the Unknown Lands"])
        return places[randi() % places.size()]
    return "the Unknown Lands"

func get_magic_name() -> String:
  match required_magic:
    MagicElement.Type.WATER: return "Water Breathing"
    MagicElement.Type.MEND: return "Mending"
    MagicElement.Type.HEAL: return "Healing"
    MagicElement.Type.FLIGHT: return "Flight"
  return "magic"

func get_equipment_name() -> String:
    if equipped_items.is_empty():
        return "their equipment"
    if equipped_items.size() == 1:
        return "their " + equipped_items[0].type
    return "their armour"

func check_outfit() -> bool:
  for requirement in customer_requirements:
    var met = false
    for stat in equipped_stats:
      # find which group this stat belongs to
      for group_key in STAT_GROUPS:
        if stat == group_key or stat in STAT_GROUPS[group_key]:
          if requirement == group_key or requirement in STAT_GROUPS[group_key]:
            met = true
    if not met:
      print("Requirement not met, customer dead: ", requirement) #Temp newspaper fail
      return false
  print("Customer happy and successful!") #Temp newspaper success
  return true

func get_newspaper_article() -> String:
  var outcome = get_newspaper_outcome()
  var magic = get_magic_name()
  var place = get_place()
  var equipment = get_equipment_name()

  match outcome:
    1:
      return customer_name + " defeated the enemy in " + place + ". " + equipment + " proved extremely valuable and impactful. They say that without it, they would have surely perished."
   # 2:
   #   return customer_name + " perished at the hands of " + enemy + " in " + place + ". " + equipment_name + " was unfortunately not enough to kill " + enemy + ". Had they prepared better, they may have succeeded."
    3:
      return customer_name + " perished during their journey through " + place + ". " + equipment + " was unfortunately not enough to withstand " + place + ". Had they prepared better, they may have succeeded."
    4:
      return customer_name + " succeeded in traversing through " + place + " to deliver their parcel, aided by the power of " + magic + ". The recipient was thrilled and the courier made their way home safely thanks to " + equipment + "."
    5:
      return customer_name + " failed in traversing through " + place + " delivering their parcel, despite having " + magic + ", it was not enough. " + equipment + " was frail and destroyed enroute. The recipient was distraught to learn of their passing."
    _:
      return "No news today."

func get_newspaper_outcome() -> int:
  print("dressup complete: ", minigames_completed["dressup"])
  print("check_outfit: ", check_outfit())
  print("typing passed: ", day_results.typing.passed)
  print("typing choice: ", day_results.typing.choice, " required: ", required_magic)
  if not minigames_completed["dressup"] or not check_outfit():
    return 3 # environment death
 # if not minigames_completed["blacksmith"] or not day_results.blacksmith.passed:
 #   return 2 # monster/enemy death
  if not minigames_completed["typing"] or not day_results.typing.passed or int(day_results.typing.choice) != int(required_magic):
    return 5 # fails mission
  else:
    return 4 # full success

func reset_day():
  equipped_items = []
  day_results.dressup.outfit = []
  day_results.blacksmith.passed = false
  day_results.typing.passed = false
  minigames_completed["dressup"] = false
  minigames_completed["blacksmith"] = false
  minigames_completed["typing"] = false
  minigames_completed["blacksmith"] = true # remove when blacksmith is in
  print("after reset: ", minigames_completed)
  randomize_day()
