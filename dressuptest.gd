extends Node2D

var finalized = false

func _on_button_pressed():
    finalized = true
    $Finalize.disabled = true  # Grey out the button
    lock_all_pieces()

func lock_all_pieces():
    print(get_tree().get_nodes_in_group("clothing").size())
    for piece in get_tree().get_nodes_in_group("clothing"):
        piece.set("locked", true)
