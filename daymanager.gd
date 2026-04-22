extends Node

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
    # add more groups as needed
}

# What the current customer requires (set this per day/customer)
var customer_requirements: Array[String] = ["icy", "insulated", "venomous"]

# What the player equipped
var equipped_stats: Array[String] = []

func check_outfit() -> bool:
    for requirement in customer_requirements:
        var group = STAT_GROUPS.get(requirement, [requirement])
        var met = false
        for stat in equipped_stats:
            if stat in group:
                met = true
                break
        if not met:
            print("Requiements not met!")
            return false  # a requirement wasn't met
    return true  # all requirements met

func reset_day():
    day_results.dressup.outfit = []
    day_results.blacksmith.passed = false
    day_results.typing.passed = false
