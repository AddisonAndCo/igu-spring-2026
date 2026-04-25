class_name MagicButton extends Button

signal pressed_with_element(kind: MagicElement.Type, color: Color)

@export var magic_kind: MagicElement.Type
@export var color_override: Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    add_theme_color_override("font_color", color_override)
    connect("pressed", _custom_pressed)

func _custom_pressed():
    pressed_with_element.emit(magic_kind, color_override)
