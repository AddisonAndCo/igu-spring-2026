class_name MagicPicker extends Control

# Called when the node enters the scene tree for the first time.
signal magic_back_requested(n: Node)
signal magic_picked(mg: MagicGame)

func _ready() -> void:
    $SelectionLayer/Container/ButtonPicker.connect("magic_kind_selected", _on_magic_picked)
    $SelectionLayer/BackButton.connect("pressed", _on_back)


func _on_back():
    magic_back_requested.emit(self)


func _on_magic_picked(magic_element: MagicElement.Type, color: Color) -> void:
  Daymanager.day_results.typing.choice = magic_element
  var mg = MagicGame.new_magic_game(magic_element, color)
  magic_picked.emit(mg)
  queue_free()


const mp_scene: PackedScene = preload("res://src/minigames/magic/magic_picker.tscn")
static func new_magic_picker() -> MagicPicker:
    return mp_scene.instantiate()
