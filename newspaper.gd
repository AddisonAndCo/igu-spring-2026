extends Control

func _ready():
    $MainArticle.text = Daymanager.get_newspaper_article()
    $Headline.text = "THE TOWN CRIER"  # whatever name idk yet

func _on_next_day_pressed():
    Daymanager.reset_day()
    get_tree().change_scene_to_file("res://newspaper.tscn")
