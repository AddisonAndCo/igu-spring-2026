extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mg = MagicGame.new_magic_game(MagicElement.Type.FLIGHT)
	add_child(mg)
