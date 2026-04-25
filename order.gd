extends Node3D

@onready var label = $OrderViewport/OrderLabel

func _ready():
  label.text = Daymanager.get_customer_dialogue()
