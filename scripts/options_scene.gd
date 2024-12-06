extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_backspace"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_mode_option_item_selected(index: int) -> void:
	match index:
		0: # 2d
			Global.is_topdown_active = true
		1:
			Global.is_topdown_active = false
	print("mode selected: ", index, " Global.is_topdown_active: ", Global.is_topdown_active)
	

func _on_map_size_option_item_selected(index: int) -> void:
	match index:
		0:
			Global.MAP_SIZE = 5
		1:
			Global.MAP_SIZE = 11
		2:
			Global.MAP_SIZE = 21
	print("map selected: ", index, " ", "Global.MAP_SIZE ", Global.MAP_SIZE)

func _on_check_button_toggled(toggled_on: bool) -> void:
	print("toggle is_ai_control: ", toggled_on)
	Global.is_ai_control = toggled_on


func _on_algo_button_toggled(toggled_on: bool) -> void:
	print("toggle algo: ", toggled_on)
	Global.is_algo = toggled_on
