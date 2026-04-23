class_name MagicCharacter extends Control

enum CharacterState {PENDING, CURRENT, DONE}

var body: String = ""
var char_state: CharacterState = CharacterState.PENDING
var slot_size: Vector2 = Vector2(40.0, 40.0)

@onready var current_highlight: ColorRect = $CurrentHighlight
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sync_visuals()


func _set_text(c: String) -> void:
	assert(c.length() == 1)
	body = c
	if is_node_ready():
		_sync_visuals()


func _set_slot_size(new_slot_size: Vector2) -> void:
	slot_size = Vector2(maxf(new_slot_size.x, 1.0), maxf(new_slot_size.y, 1.0))
	if is_node_ready():
		_sync_visuals()


func set_character_state(new_state: CharacterState) -> void:
	char_state = new_state
	if is_node_ready():
		_sync_visuals()


func play_correct_feedback() -> void:
	if !is_node_ready():
		return

	rich_text_label.scale = Vector2(1.12, 1.12)
	var tween = create_tween()
	tween.tween_property(rich_text_label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _sync_visuals() -> void:
	size = slot_size
	custom_minimum_size = slot_size

	current_highlight.position = Vector2(0.0, slot_size.y - 8.0)
	current_highlight.size = Vector2(slot_size.x, 8.0)
	rich_text_label.position = Vector2.ZERO
	rich_text_label.size = slot_size
	rich_text_label.text = body

	match char_state:
		CharacterState.PENDING:
			current_highlight.visible = false
			rich_text_label.modulate = Color(1.0, 1.0, 1.0, 0.72)
		CharacterState.CURRENT:
			current_highlight.visible = true
			rich_text_label.modulate = Color(1.0, 0.96, 0.66)
		CharacterState.DONE:
			current_highlight.visible = false
			rich_text_label.modulate = Color(0.58, 0.88, 1.0)


const magic_character_scene: PackedScene = preload("res://src/minigames/magic/magic_character.tscn")
static func new_magic_character(c: String, new_slot_size: Vector2) -> MagicCharacter:
	var character = magic_character_scene.instantiate() as MagicCharacter
	character._set_text(c)
	character._set_slot_size(new_slot_size)
	return character
