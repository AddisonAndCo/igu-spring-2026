extends Node

enum MissionType {COMBAT, DELIVERY}
var mission_type = MissionType.COMBAT # This will change per day ?
var customer_name = "Frieren"
var enemy = "the green slime"
var place = "Magnetic Mountains"
var equipment_name = "electric-resistant armour"
var customer_requirements: Array[String] = ["+Fire Resistance", "+Poison Resistance", "+Cold Resistance", "+Electric Resistance", "+Wind Resistance", "+Water Resistance"] # 1 day cycle, static for now
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

func _ready(): # TEMP JUST FOR TEST REMOVE LATER !!!!
    minigames_completed["blacksmith"] = true
    minigames_completed["typing"] = true

func _on_magic_game_complete(magic_type: String, success: bool) -> void:
    minigames_completed["typing"] = true
    day_results["typing"]["passed"] = success
    day_results["typing"]["choice"] = magic_type

func complete_minigame(game_name: String):
    minigames_completed[game_name] = true
    for game in minigames_completed:
        if not minigames_completed[game]:
            return
    emit_signal("day_complete") #trigger the newspaper

func check_day_complete():
    for game in minigames_completed:
        if not minigames_completed[game]:
            return
    emit_signal("day_complete") #trigger the newspaper

const DIALOGUE_TEMPLATES = [
    "Hello, Shopkeeper. I'm headed off on an adventure to somewhere that is {req0}, and it also needs to deal with {req1} conditions.",
    "Dear Shopkeeper, I am in need of some armour to protect me from somewhere {req0}. Oh, and also protect me from {req1} dangers.",
    "Well met, Shopkeeper. "]

# The synonym groups word is treated as same stat
const STAT_GROUPS = {
    "+Fire Resistance": ["volcanic", "hot", "desert", "boiling", "burning", "blistering", "sweltering"],
    "+Poison Resistance": ["poisonous", "toxic", "venomous", "noxious", "infected"],
    "+Cold Resistance": ["icy", "arctic", "tundra", "freezing", "chilly", "frigid"],
    "+Electric Resistance": ["electrified", "charged", "electrostatic", "energized"],
    "+Wind Resistance": ["windy", "breezy", "gusty"],
    "+Water Resistance": ["wet", "underwater", "sodden", "damp", "waterlogged", "marshy"],
    }

func get_customer_dialogue() -> String:
    var keys = STAT_GROUPS.keys()
    keys.shuffle()
    var word1 = STAT_GROUPS[keys[0]][randi() % STAT_GROUPS[keys[0]].size()]
    var word2 = STAT_GROUPS[keys[1]][randi() % STAT_GROUPS[keys[1]].size()]

    var template = DIALOGUE_TEMPLATES[randi() % DIALOGUE_TEMPLATES.size()]
    return template.replace("{req0}", word1).replace("{req1}", word2)

func check_outfit() -> bool:
    for requirement in customer_requirements:
        var met = false
        for stat in Daymanager.equipped_stats:
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
    match outcome:
        1:
            return customer_name + " defeated " + enemy + " in " + place + ". " + equipment_name + " proved extremely valuable and impactful. They say that without it, they would have surely perished."
        2:
            return customer_name + " perished at the hands of " + enemy + " in " + place + ". " + equipment_name + " was unfortunately not enough to kill " + enemy + ". Had they prepared better, they may have succeeded."
        3:
            return customer_name + " perished during their journey through " + place + ". " + equipment_name + " was unfortunately not enough to withstand " + place + ". Had they prepared better, they may have succeeded."
        4:
            return customer_name + " succeeded in traversing through " + place + " to deliver their parcel. The recipient was thrilled and the courier made their way home safely thanks to " + equipment_name + "."
        5:
            return customer_name + " failed in traversing through " + place + " delivering their parcel. " + equipment_name + " was frail and destroyed enroute. The recipient was distraught to learn of their passing."
        _:
            return "No news today."

func get_newspaper_outcome() -> int:
    if not minigames_completed["dressup"] or not check_outfit():
        return 3 # environment death
    if not minigames_completed["blacksmith"] or not day_results.blacksmith.passed:
        return 2 # monster/enemy death
    if not minigames_completed["typing"] or not day_results.typing.passed:
        return 5 # fails mission
    else:
        return 4 # full success

func reset_day():
    day_results.dressup.outfit = []
    day_results.blacksmith.passed = false
    day_results.typing.passed = false
