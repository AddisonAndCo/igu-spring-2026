extends Node3D

@onready var label = $SubViewport/Control/PanelContainer/MarginContainer/RichTextLabel

func _ready():
  label.text = Daymanager.get_customer_dialogue()
