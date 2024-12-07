extends AIController3D

# Stores the action sampled for the agent's policy, running in python
@onready var camera: Camera3D = $"../Camera3D"

var move = Vector2.ZERO
var previous_distance_to_target: float = 0
var camera_direction: Vector2 = Vector2.ZERO

const FLOOR: int = -1
const WALL: int = 0
const PELLET: int = 1
const PLAYER: int = 2

func _ready() -> void:
	super._ready()
	Signals.connect("penalty", _on_penalty)
	Signals.connect("received_reward", _on_received_reward)
	Signals.connect("on_wall", _on_penalty)
	
func get_obs() -> Dictionary:
	var obs = [
		Global.player_pos.x,
		Global.player_pos.y,
	];
	
	var flatten = flatten_2d_array(Global.grid)
	obs.append_array(flatten)

	if is_instance_valid(Global.target_pellet):
		var target_pos = to_local(Global.target_pellet.global_position)
		obs.append_array([
			target_pos.x,
			target_pos.y,
			target_pos.z
		])
	else:
		obs.append_array([
			0,
			0,
			0
		])
		done = true
		
	if _player:
		obs.append_array(_player.raycast_sensor.get_observation())

	return {"obs":obs}

func flatten_2d_array(maze: Array) -> Array:
	var flattened = []

	for row in maze:
		flattened += row

	return flattened


func get_reward() -> float:
	return reward

func get_action_space() -> Dictionary:
	return {
		"move_action": {
			"size": 4,
			"action_type": "discrete"
		},
		"camera_action": {
			"size": 1,  # Camera direction (up, down, left, right)
			"action_type": "discrete"
		}
	}

func set_action(action) -> void:
	var direction: Vector2 = Vector2.ZERO
	var new_position: Vector2
	
	if _player:
		reward += calculate_reward()

	match int(action["move_action"]):
		0: # up
			direction.x = -1
		1: # down
			direction.x = 1
		2: # left
			direction.y = -1
		3: # right
			direction.y = 1
	
	#print("Global.player_pos: ", Global.player_pos)
	new_position = Global.player_pos + direction

	if is_valid_move(new_position):
		move = new_position
		#reward += 1
		#print("Moved to: ", move)
		Signals.emit_signal("ai_move", [move])
	else:
		_on_penalty()

func is_valid_move(position: Vector2) -> bool:
	if position.x < 0 or position.y < 0 or position.x >= Global.grid.size() or position.y >= Global.grid[0].size():
		return false
	if Global.grid[int(position.x)][int(position.y)] in [FLOOR, PELLET]:
		return true
	return false

func _on_penalty():
	reward -= 1

func _on_received_reward(incoming_reward):
	print("AI controller received reward")
	reward += incoming_reward
	
func calculate_reward():
	var player_pos = to_local(_player.global_position)
	if is_instance_valid(Global.target_pellet) == false: return 0.0
	var target_pos = to_local(Global.target_pellet.global_position)
	var distance_to_target = player_pos.distance_to(target_pos)
	
	print("distance_to_target: ", distance_to_target)

	if distance_to_target < previous_distance_to_target:
		return 1.0

	if distance_to_target > previous_distance_to_target:
		return -1.0

	if distance_to_target < 1:
		end_episode()
		return 100.0
	previous_distance_to_target = distance_to_target
	return 0.0

#if _player:
	#reward += calculate_reward()
#var move_dir = move
#var camera_dir = Vector2(-camera.global_transform.basis.z.x, -camera.global_transform.basis.z.z)
#reward -= calculate_misalignment_penalty(move_dir, camera_dir) * 0.5  # Weight the penalty
#print("Current reward: ", reward)

func calculate_misalignment_penalty(move_dir: Vector2, camera_dir: Vector2) -> float:
	var move_normalized = move_dir.normalized()
	#print("move_normalized: ", move_normalized)
	var camera_normalized = camera_dir.normalized()
	#print("camera_normalized: ", camera_normalized)
	
	var alignment = move_normalized.dot(camera_normalized)
	#print("alignment: ", alignment)
	
	return 1.0 - alignment

#func _on_area_3d_area_entered(area: Area3D) -> void:
	#print("Area entered", area.name)
#
#func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("Area body entered", body.name)

func end_episode():
	done = true
	reset()
