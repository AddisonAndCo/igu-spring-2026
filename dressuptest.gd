extends Node2D

signal dressup_finished
var finalized = false

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    finalized = false
    $Finalize.disabled = false 
    print("finalize disabled: ", $Finalize.disabled)
    
func _on_button_pressed():
    finalized = true
    #$Finalize.disabled = true  (removing this to prevent softlock)
    lock_all_pieces() # Can't move anymore (redundant)
    collect_stats()
    print("about to check outfit")
    Daymanager.check_outfit()
    print("button pressed, emitting signal")
    emit_signal("dressup_finished")
    visible = false
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
    # print(get_tree().get_nodes_in_group("clothing").size())
    for piece in get_tree().get_nodes_in_group("clothing"):
        piece.set("locked", true)
