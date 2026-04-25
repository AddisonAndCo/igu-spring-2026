extends VBoxContainer


# Called when the node enters the scene tree for the first time.
signal magic_kind_selected(magic_element: MagicElement.Type, color: Color)

func _ready() -> void:
    $WaterButton.connect("pressed_with_element", _on_selection)
    $MendButton.connect("pressed_with_element", _on_selection)
    $HealButton.connect("pressed_with_element", _on_selection)
    $FlightButton.connect("pressed_with_element", _on_selection)

func _on_selection(magic_element: MagicElement.Type, color: Color) -> void:
    magic_kind_selected.emit(magic_element, color)
