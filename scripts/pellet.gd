extends Node3D

@export var noise: NoiseTexture3D
var time_passed
var origin_pos

const REWARD: int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_passed = 0
	origin_pos = global_position
	print("loc: ", self.origin_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#time_passed += delta
	#var sample_noise = noise.noise.get_noise_1d(time_passed)
#
	#position.x = origin_pos.x + sample_noise * 5
	#position.y = origin_pos.y + sample_noise * 10

	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		#print("Player entered the area!")
		Signals.emit_signal("received_reward", REWARD)
		queue_free()
