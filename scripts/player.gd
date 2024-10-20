extends CharacterBody3D

class_name Player

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

var camera: Camera3D
var mouse_sensitivity: float = 0.001
var camera_rotation: Vector2 = Vector2(0.0,0.0)

@export var camera_lock: Camera3D
@onready var visual: MeshInstance3D = $LowPoly_PacMan

func _ready() -> void:
	camera = get_node("../TopDownCamera")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent):
	if event is InputEventMouseMotion and camera_lock.current == false:
		var MouseEvent = event.relative * mouse_sensitivity
		camera_look(MouseEvent)

func camera_look(Movement: Vector2) -> void:
	camera_rotation += Movement
	
	transform.basis = Basis()
	camera.transform.basis = Basis()

	rotate_object_local(Vector3(0,1,0),-camera_rotation.x)
	camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
