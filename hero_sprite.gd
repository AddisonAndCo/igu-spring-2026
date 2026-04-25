extends Sprite3D

func _ready():
    Daymanager.day_randomized.connect(_on_day_randomized)
    _on_day_randomized()

func _on_day_randomized():
    texture = Daymanager.current_character.sprite
