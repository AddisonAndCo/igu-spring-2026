extends Node

var customer_requirements: Array[String] = ["icy", "insulted", "venomous"] # 1 day cycle, static for now
var equipped_stats: Array[String] = [] # What the player equipped
var passed = Daymanager.check_outfit()

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

# The synonym groups word is treated as same stat
const STAT_GROUPS = {
    "+Fire Resistance": ["volcanic", "hot"],
    "+Poison Resistance": ["poisonous", "toxic", "venomous"],
    "+Cold Resistance": ["icy", "frozen"],
    "+Electric Resistance": ["insulated", "shocking", "electric", "sparkling"],
    "+Wind Resistance": ["windy", "high altitude", "high altitudes"],
    "+Water Resistance": ["wet", "underwater"],
}


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
