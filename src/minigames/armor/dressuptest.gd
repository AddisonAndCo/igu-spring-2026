extends Node2D

signal dressup_back_requested(n: Node)
signal dressup_finished

var finalized = false

func _ready():
  process_mode = Node.PROCESS_MODE_ALWAYS
  finalized = false
  $Finalize.disabled = false

  $BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
  dressup_back_requested.emit(self)

func _on_button_pressed():
  print("button pressed!!!")
  finalized = true
  #$Finalize.disabled = true  (removing this to prevent softlock)
  lock_all_pieces() # Can't move anymore (redundant)
  collect_stats()
  Daymanager.complete_minigame("dressup")
  Daymanager.check_outfit()
  emit_signal("dressup_finished")
  visible = false
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # re-enable player movement

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
