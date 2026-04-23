extends Node3D

const MagicElement = preload("res://assets/minigames/magic/magic_element.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mg = MagicGame.new_magic_game(MagicElement.Type.ICE)
	$SubViewportContainer.add_child(mg)
