class_name MagicText extends Control

var bank: String = ""
var index: int = 0

@export var horizontal_margin: float = 120.0
@export var vertical_margin: float = 60.0
@export var line_height: float = 62.0
@export var letter_spacing: float = 2.0
@export var word_spacing: float = 18.0
@export var line_scroll_duration: float = 0.18
@export var wrong_flash_color: Color = Color(1.0, 0.45, 0.45)
@export var wrong_flash_duration: float = 0.16
@export var wrong_shake_distance: float = 14.0
@export var correct_key_sfx: AudioStream
@export var done_fill_color: Color

var characters: Array[MagicCharacter] = []
var character_line_indices: Array[int] = []
var line_centers: Array[float] = []
var scroll_tween: Tween
var wrong_feedback_tween: Tween

@onready var characters_layer: Control = $CharactersLayer
@onready var correct_key_player: AudioStreamPlayer = $CorrectKeyPlayer

signal word_complete

func _ready() -> void:
    resized.connect(_layout_text)
    call_deferred("_layout_text")


func try_advance(i: String) -> bool:
    if index >= bank.length() or index >= characters.size():
        return false

    if bank[index] == i:
        characters[index].play_correct_feedback()
        _play_correct_key_sfx()
        if (bank[index] == " "):
            word_complete.emit()
        index += 1
        _update_character_states()
        _update_line_visibility()
        _update_scroll_position()
        return true

    play_wrong_feedback()
    return false;


func play_wrong_feedback() -> void:
    if !is_node_ready():
        return

    if wrong_feedback_tween != null:
        wrong_feedback_tween.kill()

    characters_layer.position.x = 0.0
    characters_layer.modulate = Color.WHITE

    wrong_feedback_tween = create_tween()
    wrong_feedback_tween.parallel().tween_property(characters_layer, "modulate", wrong_flash_color, wrong_flash_duration * 0.5)
    wrong_feedback_tween.parallel().tween_property(characters_layer, "position:x", wrong_shake_distance, wrong_flash_duration * 0.2)
    wrong_feedback_tween.tween_property(characters_layer, "position:x", -wrong_shake_distance, wrong_flash_duration * 0.25)
    wrong_feedback_tween.tween_property(characters_layer, "position:x", wrong_shake_distance * 0.6, wrong_flash_duration * 0.2)
    wrong_feedback_tween.parallel().tween_property(characters_layer, "modulate", Color.WHITE, wrong_flash_duration)
    wrong_feedback_tween.tween_property(characters_layer, "position:x", 0.0, wrong_flash_duration * 0.35)


func _play_correct_key_sfx() -> void:
    if correct_key_sfx == null:
        return

    correct_key_player.stream = correct_key_sfx
    correct_key_player.play()


func _layout_text() -> void:
    if !is_node_ready():
        return

    var previous_index = index
    for child in characters_layer.get_children():
        child.queue_free()

    characters.clear()
    character_line_indices.clear()
    line_centers.clear()

    if bank.is_empty():
        index = 0
        characters_layer.position = Vector2.ZERO
        return

    var line_layouts = _build_line_layouts(bank.split(" ", false))
    var available_width = _get_available_width()
    var line_height_value = _get_line_height()
    var total_height = line_layouts.size() * line_height_value
    var start_y = maxf((_get_available_height() - total_height) * 0.5, vertical_margin)

    for line_index in range(line_layouts.size()):
        var line_layout: Dictionary = line_layouts[line_index]
        var line_width := float(line_layout["width"])
        var line_x = horizontal_margin + maxf((available_width - line_width) * 0.5, 0.0)
        var line_y = start_y + (line_index * line_height_value)
        line_centers.append(line_y + (line_height_value * 0.5))

        for entry in line_layout["characters"]:
            var character_text := String(entry["text"])
            var slot_size: Vector2 = entry["size"]
            var entry_x := float(entry["x"])
            var character_node = MagicCharacter.new_magic_character(character_text, slot_size, done_fill_color)
            character_node.position = Vector2(line_x + entry_x, line_y)
            characters_layer.add_child(character_node)
            characters.append(character_node)
            character_line_indices.append(line_index)

    index = mini(previous_index, characters.size())
    _update_character_states()
    _update_line_visibility()
    _update_scroll_position(false)


func _update_character_states() -> void:
    for character_index in range(characters.size()):
        if character_index < index:
            characters[character_index].set_character_state(MagicCharacter.CharacterState.DONE)
        elif character_index == index:
            characters[character_index].set_character_state(MagicCharacter.CharacterState.CURRENT)
        else:
            characters[character_index].set_character_state(MagicCharacter.CharacterState.PENDING)


func _update_scroll_position(animated: bool = true) -> void:
    if line_centers.is_empty():
        return

    var active_line_index = _get_active_line_index()
    var target_y = (_get_available_height() * 0.5) - line_centers[active_line_index]

    if scroll_tween != null:
        scroll_tween.kill()

    if !animated:
        characters_layer.position.y = target_y
        return

    scroll_tween = create_tween()
    scroll_tween.tween_property(characters_layer, "position:y", target_y, line_scroll_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _update_line_visibility() -> void:
    if character_line_indices.is_empty():
        return

    var active_line_index = _get_active_line_index()
    for character_index in range(characters.size()):
        characters[character_index].visible = character_line_indices[character_index] <= active_line_index + 1


func _get_active_line_index() -> int:
    if character_line_indices.is_empty():
        return 0

    var clamped_index = mini(index, character_line_indices.size() - 1)
    return character_line_indices[clamped_index]


func _get_line_height() -> float:
    var font = get_theme_default_font()
    var font_size = get_theme_default_font_size()

    if font == null:
        return line_height

    return maxf(line_height, font.get_height(font_size) + 12.0)


func _get_available_width() -> float:
    var available_width = size.x
    if available_width <= 0.0:
        available_width = get_viewport_rect().size.x
    return maxf(1.0, available_width - (horizontal_margin * 2.0))


func _get_available_height() -> float:
    var available_height = size.y
    if available_height <= 0.0:
        available_height = get_viewport_rect().size.y
    return maxf(1.0, available_height)


func _build_line_layouts(words: PackedStringArray) -> Array[Dictionary]:
    var line_layouts: Array[Dictionary] = []
    var line_characters: Array[Dictionary] = []
    var current_line_width := 0.0
    var max_width = _get_available_width()
    var line_height_value = _get_line_height()
    var space_size = _measure_character_slot(" ")
    space_size.x = maxf(space_size.x, word_spacing)
    space_size.y = line_height_value

    for word in words:
        var word_entries = _build_word_entries(word, line_height_value)
        var word_width = _measure_entries_width(word_entries)
        var predicted_width = word_width if line_characters.is_empty() else current_line_width + space_size.x + word_width

        if !line_characters.is_empty() and predicted_width > max_width:
            line_characters.append({"text": " ", "size": space_size, "x": current_line_width})
            current_line_width += space_size.x
            line_layouts.append({"width": current_line_width, "characters": line_characters})
            line_characters = []
            current_line_width = 0.0

        if !line_characters.is_empty():
            line_characters.append({"text": " ", "size": space_size, "x": current_line_width})
            current_line_width += space_size.x

        for entry in word_entries:
            line_characters.append({
                "text": entry["text"],
                "size": entry["size"],
                "x": current_line_width + entry["x"],
            })

        current_line_width += word_width

    if !line_characters.is_empty():
        line_layouts.append({"width": current_line_width, "characters": line_characters})

    return line_layouts


func _build_word_entries(word: String, line_height_value: float) -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    var x := 0.0

    for char_index in range(word.length()):
        var character_text = word.substr(char_index, 1)
        var slot_size = _measure_character_slot(character_text)
        slot_size.y = line_height_value
        entries.append({
            "text": character_text,
            "size": slot_size,
            "x": x,
        })
        x += slot_size.x
        if char_index < word.length() - 1:
            x += letter_spacing

    return entries


func _measure_entries_width(entries: Array[Dictionary]) -> float:
    if entries.is_empty():
        return 0.0

    var last_entry = entries[entries.size() - 1]
    var last_x := float(last_entry["x"])
    var last_size: Vector2 = last_entry["size"]
    return last_x + last_size.x


func _measure_character_slot(character: String) -> Vector2:
    var font = get_theme_default_font()
    var font_size = get_theme_default_font_size()

    if font == null:
        return Vector2(24.0, _get_line_height())

    var measured_size = font.get_string_size(character, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
    return Vector2(maxf(measured_size.x, 12.0), _get_line_height())


const magic_text_scene: PackedScene = preload("res://src/minigames/magic/magic_text.tscn")
static func new_magic_text(body: String, color: Color) -> MagicText:
    var ret = magic_text_scene.instantiate() as MagicText
    ret.bank = body
    ret.done_fill_color = color
    return ret
