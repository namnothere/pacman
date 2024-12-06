extends AIController3D

# Stores the action sampled for the agent's policy, running in python
var move_action : float = 0.0
var move = Vector2.ZERO
var previous_distance_to_target: float = 0

func _ready() -> void:
	super._ready()
	Signals.connect("penalty", _on_penalty)
	Signals.connect("received_reward", _on_received_reward)
	Signals.connect("on_wall", _on_penalty)

func get_obs() -> Dictionary:
	# get the balls position and velocity in the paddle's frame of reference
	#var ball_pos = to_local(_player.ball.global_position)
	#var ball_vel = to_local(_player.ball.linear_velocity)
	#var obs = [ball_pos.x, ball_pos.z, ball_vel.x/10.0, ball_vel.z/10.0]
	
	var target_pos = to_local(Global.target_pellet.global_position)
	
	var obs = [
		target_pos.x,
		target_pos.y,
		target_pos.z
	]
	if _player:
		var player_pos = to_local(_player.global_position)
		obs.append_array([
			player_pos.x,
			player_pos.y,
			player_pos.z,
		])
		obs.append_array(_player.raycast_sensor.get_observation())
		#obs.append_array(
		#[
			#_player.move_vec.x / _player.MOVE_SPEED,
			#_player.move_vec.y / _player.MAX_FALL_SPEED,
			#_player.move_vec.z / _player.MOVE_SPEED
		#]
	#)

	return {"obs":obs}

func get_reward() -> float:
	return reward

func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 2,
			"action_type": "continuous"
		},
		"camera_action": {
			"size": 2,
			"action_type": "continuous"
		}
	}

func set_action(action) -> void:
	#move_action = clamp(action["move_action"][0], -1.0, 1.0)
	move.x = action["move_action"][0]
	move.y = action["move_action"][1]

func _on_penalty():
	reward -= 0.01

func _on_received_reward(incoming_reward):
	print("AI controller received reward")
	reward += incoming_reward
	
func calculate_reward():
	var player_pos = to_local(_player.global_position)
	if is_instance_valid(Global.target_pellet) == false: return 0.0
	var target_pos = to_local(Global.target_pellet.global_position)
	var distance_to_target = player_pos.distance_to(target_pos)

	if distance_to_target < previous_distance_to_target:
		return 1.0

	if distance_to_target > previous_distance_to_target:
		return -1.0

	if distance_to_target < 0.1:
		return 100.0
	previous_distance_to_target = distance_to_target
	return 0.0

func _physics_process(_delta: float) -> void:
	if _player:
		reward += calculate_reward()
		print("Current reward: ", reward)

#func _on_area_3d_area_entered(area: Area3D) -> void:
	#print("Area entered", area.name)
#
#func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("Area body entered", body.name)
