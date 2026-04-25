extends Sprite2D
var dragging : bool = false
var locked: bool = false
var of : Vector2 = Vector2(0,0)
var home_pos : Vector2
var small_scale = Vector2(0.1, 0.1)
var full_scale = Vector2(0.25, 0.25)
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@export var stats: Array[String] = [] # What kind of stat it provides
@onready var stat_label = $StatLabel # Displays

@export var item_type: String = "" # What kind of item it is

func _ready():
  home_pos = global_position
  z_index = 0
  scale = small_scale
  stat_label.visible = false

func _input(event: InputEvent) -> void:
  if event is InputEventMouseButton:
    if event.pressed:
      if locked:
        return
      var mouse = get_global_mouse_position()
      if global_position.distance_to(mouse) < 180:
        scale = full_scale
        of = mouse - global_position
        dragging = true
        z_index = 100
    else:
      if dragging:
        dragging = false
        check_snap()

func _process(_delta: float) -> void:
  if dragging:
    position = get_global_mouse_position() - of
    z_index = 10

func check_snap():
  for zone in get_tree().get_nodes_in_group("snap_zones"):
    if global_position.distance_to(zone.global_position) < 100:
      if item_type in zone.accepted_items:
        global_position = zone.global_position
        z_index = 10
        audio_stream_player.play()
        stat_label.visible = true
        stat_label.text = "\n".join(stats)
        Daymanager.equipped_items.append({"type": item_type})
        return
  scale = small_scale
  global_position = home_pos
  stat_label.visible = false
