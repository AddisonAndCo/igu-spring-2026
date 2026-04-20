class_name MagicGame extends Node

@export var element: MagicElement.Type

# Should games be themed?
# Core: take word bank and randomize selection and ordering
# display words for the player to type out
# kick off a 20 second timer, record wpm
# input - enum representing type of spell (ice, fire, electric, earth, wind, poison)
# output - wpm, to be converted into a score by a higher layer
# edge cases:
# typo - set off a signal, do not advance the cursor
# player types all the words - unlikely but in this case I guess they'd auto win

# TODOE_NAME = "Ch
# X define elemental enum
# X define class that takes in enum and retrieves corresponding word bank
# on class creation, randomize word bank and present to player
# enable keyboard inputs to control cursor
# set timer and scoring stuff

static var bank_root = "res://assets/minigames/magic/"

var bank: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var e_str = str(MagicElement.Type.keys()[element]).to_lower()
	var path = bank_root + e_str + ".yaml"
	var parser = YAMLParser.new()

	var yfile = FileAccess.open(path, FileAccess.READ)
	var yaml = yfile.get_as_text()
	yfile.close()

	var yraw = parser.parse(yaml)
	bank = yraw['words']
	randomize()
	bank.shuffle()

	print(bank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Factory function
const magic_game_scene: PackedScene = preload("res://src/minigames/magic/magic_game.tscn")
static func new_magic_game(el: MagicElement.Type) -> MagicGame:
	var mg = magic_game_scene.instantiate()
	mg.element = el
	return mg
