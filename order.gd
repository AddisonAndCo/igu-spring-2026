extends Sprite3D

@onready var label = $Label3D

func _ready():
    label.text = Daymanager.get_customer_dialogue()
