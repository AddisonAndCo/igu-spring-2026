extends Control

func _ready():
    $MarginContainer/MainArticle.text = Daymanager.get_newspaper_article()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    # $Headline.text = "THE TOWN CRIER"  # whatever name idk yet
    $NextDay.pressed.connect(_on_next_day_pressed)

func _on_next_day_pressed():
    print("next day pressed!")
    Daymanager.reset_day()
    print("blacksmith after reset: ", Daymanager.minigames_completed["blacksmith"])
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    print("changing scene...")
    get_tree().change_scene_to_file("res://main_3d.tscn")
    print("scene changed")
