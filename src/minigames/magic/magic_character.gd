class_name MagicCharacter extends Control

enum CharacterState {PENDING, CURRENT, DONE}

@export var done_fill_color: Color = Color(0.58, 0.88, 1.0)
@export var hit_particle_color: Color = done_fill_color

var body: String = ""
var char_state: CharacterState = CharacterState.PENDING
var slot_size: Vector2 = Vector2(40.0, 40.0)
var shake_phase: float = 0.0

const PENDING_SHAKE_AMPLITUDE := 1.6
const PENDING_SHAKE_SPEED := 7.0
const HIT_PARTICLE_COUNT := 6
const HIT_PARTICLE_MIN_DISTANCE := 12.0
const HIT_PARTICLE_MAX_DISTANCE := 30.0
const HIT_PARTICLE_DURATION := 0.22

@onready var current_highlight: ColorRect = $CurrentHighlight
@onready var hit_particles: Control = $HitParticles
@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    shake_phase = float(get_instance_id() % 360)
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
    _emit_hit_particles()
    var tween = create_tween()
    tween.tween_property(rich_text_label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
    shake_phase += delta * PENDING_SHAKE_SPEED

    if char_state == CharacterState.PENDING:
        rich_text_label.position = Vector2(
            sin(shake_phase) * PENDING_SHAKE_AMPLITUDE,
            cos(shake_phase * 1.37) * PENDING_SHAKE_AMPLITUDE
        )
    else:
        rich_text_label.position = Vector2.ZERO


func _sync_visuals() -> void:
    size = slot_size
    custom_minimum_size = slot_size

    current_highlight.position = Vector2(0.0, slot_size.y - 8.0)
    current_highlight.size = Vector2(slot_size.x, 8.0)
    hit_particles.size = slot_size
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
            rich_text_label.modulate = done_fill_color


func _emit_hit_particles() -> void:
    for child in hit_particles.get_children():
        child.queue_free()

    var center = slot_size * 0.5
    var base_angle = deg_to_rad(float(get_instance_id() % 360))

    for particle_index in range(HIT_PARTICLE_COUNT):
        var particle = ColorRect.new()
        var particle_size = Vector2(4.0, 4.0)
        var angle = base_angle + ((TAU / HIT_PARTICLE_COUNT) * particle_index)
        var distance = lerpf(HIT_PARTICLE_MIN_DISTANCE, HIT_PARTICLE_MAX_DISTANCE, float(particle_index + 1) / float(HIT_PARTICLE_COUNT))
        var direction = Vector2(cos(angle), sin(angle))

        particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
        particle.color = hit_particle_color.lerp(done_fill_color, 0.35)
        particle.size = particle_size
        particle.position = center - (particle_size * 0.5)
        hit_particles.add_child(particle)

        var tween = create_tween()
        tween.parallel().tween_property(particle, "position", center + (direction * distance) - (particle_size * 0.5), HIT_PARTICLE_DURATION).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
        tween.parallel().tween_property(particle, "scale", Vector2(0.25, 0.25), HIT_PARTICLE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
        tween.parallel().tween_property(particle, "modulate:a", 0.0, HIT_PARTICLE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
        tween.finished.connect(particle.queue_free)


const magic_character_scene: PackedScene = preload("res://src/minigames/magic/magic_character.tscn")
static func new_magic_character(c: String, new_slot_size: Vector2, fill_color: Color) -> MagicCharacter:
    var character = magic_character_scene.instantiate() as MagicCharacter
    character._set_text(c)
    character._set_slot_size(new_slot_size)
    character.done_fill_color = fill_color
    return character
