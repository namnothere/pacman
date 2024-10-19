extends Node3D

@export var noise: NoiseTexture3D
var time_passed
var origin_pos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_passed = 0
	origin_pos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	var sample_noise = noise.noise.get_noise_1d(time_passed)

	position.x = origin_pos.x + sample_noise * 5
	position.y = origin_pos.y + sample_noise * 10

func _on_area_3d_body_entered(_body: Node3D) -> void:
	print("Scored")
	queue_free()
