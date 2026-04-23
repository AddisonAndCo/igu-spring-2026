extends Node

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

const DIALOGUE_TEMPLATES = [
  "Hello, shopkeeper. I'm headed off on an adventure to somewhere that is {req0}, and it also needs to deal with {req1} conditions.",
  "Dear shopkeeper, I am in need of some armour to protect me from somewhere {req0}. Oh, and also protect me from {req1} dangers."
  ]

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
            print("Requirement not met, customer dead: ", requirement) #Temp newspaper
            return false
    print("Customer happy and successful!")
    return true
  
func reset_day():
    day_results.dressup.outfit = []
    day_results.blacksmith.passed = false
    day_results.typing.passed = false
