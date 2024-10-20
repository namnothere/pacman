extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("disable_camera", _disable_camera)
	
func _disable_camera():
	print("Disable camera")
	pass
