class_name MagicGame extends Node

@export var element: MagicElement.Type

# Should games be themed?
# Core: take word bank and randomize selection and ordering
# display words for the player to type out
# kick off a 20 second timer, record wpm
# input - enum representing type of spell (ice, fire, electric, earth, wind, poison)
# output - wpm, to be converted into a score by a higher layer
# edge cases:
# typo - set off a signal, do not advance the cursor
# player types all the words - unlikely but in this case I guess they'd auto win

# TODOE_NAME = "Ch
# X define elemental enum
# X define class that takes in enum and retrieves corresponding word bank
# X on class creation, randomize word bank
# present text, allow for styling
# enable keyboard inputs to control cursor
# set timer and scoring stuff

signal magic_game_complete(magic_element: String, passed_threshold: bool)

static var bank_root = "res://assets/minigames/magic/"
const SUCCESS_THRESHOLD: int = 50 #wpm

var el
var wpm: int = 0
var timer_started_once: bool = false

var mt: MagicText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    el = str(MagicElement.Type.keys()[element]).to_lower()
    var path = bank_root + el + ".yaml"
    var parser = YAMLParser.new()

    var yfile = FileAccess.open(path, FileAccess.READ)
    var yaml = yfile.get_as_text()
    yfile.close()

    var yraw = parser.parse(yaml)
    var bank_arr = yraw['words']
    randomize()
    bank_arr.shuffle()

#	compensate for a word shortage by just duplicating the bank 5x
    var bank: String = ""
    for i in range(5):
        for word in bank_arr.slice(0, bank_arr.size() - 1):
            bank += word + " "
        bank += bank_arr[bank_arr.size() - 1]

    mt = MagicText.new_magic_text(bank)
    add_child(mt)

    _update_timer_display()
    wpm = 0
    mt.connect("word_complete", _on_word_complete)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    _update_timer_display()


func _unhandled_key_input(event: InputEvent) -> void:
    if !(event is InputEventKey):
        return

    var key_event := event as InputEventKey
    if !key_event.pressed or key_event.echo:
        return

    if $Timer.is_stopped() and !timer_started_once:
        $Timer.start()
        timer_started_once = true

    var input = key_event.as_text().to_lower()
    input = " " if input == "space" else input

    if input.length() != 1:
        return

    mt.try_advance(input)

func _on_word_complete() -> void:
    wpm += 1


func _on_timeout():
    wpm = wpm * (60.0 / $Timer.wait_time)
    _update_timer_display()
    set_process_unhandled_key_input(false)
    magic_game_complete.emit(el, wpm > 40)


func _update_timer_display() -> void:
    var remaining_seconds: int

    if !timer_started_once:
        remaining_seconds = int(ceil($Timer.wait_time))
    elif $Timer.is_stopped():
        remaining_seconds = 0
    else:
        remaining_seconds = int(ceil($Timer.time_left))

    $debug_counter.text = str(remaining_seconds)


# Factory function
const magic_game_scene: PackedScene = preload("res://src/minigames/magic/magic_game.tscn")
static func new_magic_game(elm: MagicElement.Type) -> MagicGame:
    var mg = magic_game_scene.instantiate()
    mg.element = elm
    return mg
