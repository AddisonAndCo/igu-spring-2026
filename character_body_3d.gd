extends CharacterBody3D

const SPEED = 5.0
# const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003
const GRAVITY = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var ray = $Head/Camera3D/RayCast3D

var highlighted_object = null
# var outline_material = preload("res://outline.tres")

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
func _process(delta):
    var hit = ray.get_collider()
    
    # Climb up to Node3D with the hover script
    var hover_object = null
    if hit:
        var parent = hit.get_parent() # MeshInstance3D
        if parent:
            var grandparent = parent.get_parent() # Node3D
            if grandparent and grandparent.has_method("on_hover_enter"):
                hover_object = grandparent
    
    if hover_object != highlighted_object:
        if highlighted_object and highlighted_object.has_method("on_hover_exit"):
            highlighted_object.on_hover_exit()
        
        if hover_object:
            hover_object.on_hover_enter()
        
        highlighted_object = hover_object

func _input(event):
    if event is InputEventMouseMotion:
        # Accumulate rotation manually
        var new_x = head.rotation.x - event.relative.y * MOUSE_SENSITIVITY
        var new_y = head.rotation.y - event.relative.x * MOUSE_SENSITIVITY
        
        # Clamp before applying
        head.rotation.x = clamp(new_x, deg_to_rad(-60), deg_to_rad(60))
        head.rotation.y = clamp(new_y, deg_to_rad(-90), deg_to_rad(90))
    
    if event.is_action_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        
func _physics_process(delta):
    # Just looking around w gravity
    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    move_and_slide()
    
    
