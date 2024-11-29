extends Node


func _ready() -> void:
	#WinScene.hide()
	print("hide winscene")
	#Signals.connect("found_solution", _on_found_solution)
	Signals.connect("update_tile_map", _on_update_tile_map)
	Signals.connect("update_target_map", _on_update_target_map)
	#coin_collected
	Signals.connect("coin_collected", _on_coin_collected)

#func _on_found_solution(solution: Array):
	#SolutionLabel.set_text(", ".join(solution))
	#print(solution)
	
func _on_update_tile_map(tile_map):
	print("Updated GameUI tile map")
	#GameUi.update_tile_map(tile_map)

func _on_update_target_map(target_map):
	print("Updated GameUI target map")
	#GameUi.update_target_map(target_map)

func _on_coin_collected(total_coins):
	print("total_coins: ", total_coins)
