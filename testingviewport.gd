extends SubViewport

@onready var testlabel = $testinglabel

func _ready():
  testlabel.text = Daymanager.get_customer_dialogue()
