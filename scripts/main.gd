extends Node2D

# Entry-point scene script. _ready() runs once when the scene loads;
# _process() runs every frame; _input() runs on each input event.


func _ready() -> void:
	print("Main scene loaded. Engine version: %s" % Engine.get_version_info().string)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		$Label.text = "Spacebar pressed at %.1fs" % (Time.get_ticks_msec() / 1000.0)
