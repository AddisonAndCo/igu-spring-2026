extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.003
const GRAVITY = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var ray = $Head/Camera3D/RayCast3D
@onready var dressup_layer = get_node("/root/main3d/CanvasLayer2")
@onready var dressup = get_node("/root/main3d/CanvasLayer2/DressupGame")
@onready var dressup_trigger = get_node("/root/main3d/shop/Old Lantern")

var highlighted_object = null
var in_minigame = false

func _ready():
    dressup_layer.visible = false
    dressup.visible = false
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    dressup_trigger.clicked.connect(_on_dressup_clicked)
    dressup.dressup_finished.connect(_on_dressup_closed)

func _on_dressup_clicked():
    in_minigame = true
    dressup_layer.visible = true
    dressup.visible = true
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    if highlighted_object:
        highlighted_object.on_hover_exit()
        highlighted_object = null

func _on_dressup_closed():
    dressup_layer.visible = false
    dressup.visible = false
    in_minigame = false
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
    if in_minigame:
        return
    var hit = ray.get_collider()
    var hover_object = null
    if hit:
        var parent = hit.get_parent()
        if parent:
            var grandparent = parent.get_parent()
            if grandparent and grandparent.has_method("on_hover_enter"):
                hover_object = grandparent
    if hover_object != highlighted_object:
        if highlighted_object and highlighted_object.has_method("on_hover_exit"):
            highlighted_object.on_hover_exit()
        if hover_object:
            hover_object.on_hover_enter()
        highlighted_object = hover_object

func _input(event):
    if in_minigame:
        if event is InputEventMouseMotion:
            return
    if event is InputEventMouseMotion:
        var new_x = head.rotation.x - event.relative.y * MOUSE_SENSITIVITY
        var new_y = head.rotation.y - event.relative.x * MOUSE_SENSITIVITY
        head.rotation.x = clamp(new_x, deg_to_rad(-60), deg_to_rad(60))
        head.rotation.y = clamp(new_y, deg_to_rad(-120), deg_to_rad(120))
    if event is InputEventMouseButton and event.pressed:
        if highlighted_object:
            highlighted_object.emit_signal("clicked")
            get_viewport().set_input_as_handled()
    if event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    move_and_slide()
