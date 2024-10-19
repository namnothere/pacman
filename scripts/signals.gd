extends Node

#signal state_update(node)
#signal selected(node)
signal coin_collected(total_coins)
func _ready():
	#connect('state_update', _on_state_update)
	#connect('selected', _on_state_update)
	connect('coin_collected', _on_coin_collected)


func _on_state_update(node):
	if node is Camera2D:
		emit_signal('camera_state_update', node)
	if node is Player:
		emit_signal('player_state_update', node)

func _on_coin_collected(total_coins):
	pass
