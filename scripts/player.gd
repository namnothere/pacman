extends CharacterBody3D

class_name Player

@export var top_down_camera: Camera3D
@onready var visual: MeshInstance3D = $LowPoly_PacMan
@onready var character_camera: Camera3D = $Camera3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity: float = 0.001
var camera_rotation: Vector2 = Vector2(0.0,0.0)
var is_moving: bool = false
var move_direction: Vector3

var is_first_person: bool = false


func _ready() -> void:
	#camera = get_node("../TopDownCamera")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	is_first_person = bool(top_down_camera.current == false)
	print("is_first_person: ", is_first_person)
	
func _input(event: InputEvent):
	if event is InputEventMouseMotion and is_first_person == true:
		var MouseEvent = event.relative * mouse_sensitivity
		camera_look(MouseEvent)
		#return
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		move_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_direction and is_first_person == false:
		is_moving = true

func camera_look(Movement: Vector2) -> void:
	camera_rotation += Movement
	
	transform.basis = Basis()
	character_camera.transform.basis = Basis()

	rotate_object_local(Vector3(0,1,0),-camera_rotation.x)
	character_camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

func _physics_process(delta: float) -> void:
	# Add the gravity only when in first person view.
	#if not is_on_floor() and is_first_person == true:
		#velocity += get_gravity() * delta

	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	#if move_direction:
		#velocity.x = move_direction.x * SPEED
		#velocity.z = move_direction.z * SPEED
		#
		#if is_first_person == true:
			#move_direction = Vector3.ZERO
		#
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
	
	if is_first_person == true:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		move_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if move_direction:
		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED
		
		if is_first_person == true:
			move_direction = Vector3.ZERO
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
