extends CanvasLayer

@onready var rect = $ColorRect

func _ready():
  rect.color.a = 0.0

func fade_out(time := 0.5):
  var tween = create_tween()
  tween.tween_property(rect, "color:a", 1.0, time)
  await tween.finished

func fade_in(time := 0.5):
  var tween = create_tween()
  tween.tween_property(rect, "color:a", 0.0, time)
  await tween.finished
