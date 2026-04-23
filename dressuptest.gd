extends Node2D

signal dressup_finished
var finalized = false

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    
#func _input(event):
    # if event is InputEventMouseButton:
       # print("dressup received click at: ", event.position)
       # for piece in get_tree().get_nodes_in_group("clothing"):
         #   print(piece.name, " position: ", piece.global_position)

func _on_button_pressed():
    finalized = true
    $Finalize.disabled = true  # Grey out the button
    lock_all_pieces()
    collect_stats()
    visible = false
    emit_signal("dressup_finished")
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    # re-enable player movement
    
func collect_stats():
    var all_stats: Array[String] = []
    for piece in get_tree().get_nodes_in_group("clothing"):
        if piece.global_position != piece.home_pos:  # only collect snapped pieces
            all_stats.append_array(piece.stats)
    Daymanager.equipped_stats = all_stats
    print("Equipped stats: ", all_stats)  # debug

func lock_all_pieces():
    print(get_tree().get_nodes_in_group("clothing").size())
    for piece in get_tree().get_nodes_in_group("clothing"):
        piece.set("locked", true)
