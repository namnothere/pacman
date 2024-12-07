extends CharacterBody3D

class_name Player

@export var top_down_camera: Camera3D
@export var is_ai_control: bool = false
@onready var character_camera: Camera3D = $Camera3D
@onready var ai_controller = $AIController3D
@onready var raycast_sensor = $RayCastSensor3D
@onready var visuals: Node3D = $visuals

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
var CHARACTER_SCALE: int = 4

var mouse_sensitivity: float = 0.001
var camera_rotation: Vector2 = Vector2(0.0,0.0)
var is_moving: bool = false
var move_direction: Vector3

var is_first_person: bool = false
var is_auto: bool = false

func _ready() -> void:
	is_first_person = bool(Global.is_topdown_active == false)
	is_ai_control = Global.is_ai_control
	#scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)

	print("is_first_person: ", is_first_person)
	if is_first_person:
		CHARACTER_SCALE = 2
	if is_ai_control:
		Signals.connect("game_over", _on_game_over)
		ai_controller.init(self)
	if is_first_person and is_ai_control == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Global.is_algo == false and Global.is_topdown_active == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Global.is_algo == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#visuals.scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)

func _on_game_over():
	ai_controller.done = true
	ai_controller.needs_reset = true

func _input(event: InputEvent):
	if event is InputEventMouseMotion and is_first_person == true and is_ai_control == false:
		var MouseEvent = event.relative * mouse_sensitivity
		camera_look(MouseEvent)
	
	if event is InputEventMouseMotion and Global.is_algo == false and Global.is_topdown_active == false:
		var MouseEvent = event.relative * mouse_sensitivity
		camera_look(MouseEvent)
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir and is_auto == false:
		move_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_direction and is_first_person == false:
		is_moving = true

func camera_look(Movement: Vector2) -> void:
	camera_rotation += Movement
	
	transform.basis = Basis()
	character_camera.transform.basis = Basis()

	rotate_object_local(Vector3(0,1,0),-camera_rotation.x)
	character_camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y)
	#scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)
	visuals.scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)

func camera_fixed_at(direction: Vector2):
	var angle: float = 180
	
	if direction == Vector2(1, 0):
		angle = 180.0
	elif direction == Vector2(-1, 0):
		angle = 0.0
	elif direction == Vector2(0, 1):
		angle = -90
	elif direction == Vector2(0, -1):
		angle = 90
	
	transform.basis = Basis()
	rotate_object_local(Vector3(0, 1, 0), deg_to_rad(angle))
	
	#scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)
	visuals.scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)

func _physics_process(_delta: float) -> void:
	
	if is_on_wall():
		#Signals.emit_signal("on_wall")
		ai_controller.reward -= 1
		ai_controller.reset()
	else:
		pass

	if is_ai_control:
		if ai_controller.needs_reset:
			ai_controller.reset()
			return
			
		#var movement : float
		#if ai_controller.heuristic == "human":
			#movement = Input.get_axis("rotate_anticlockwise", "rotate_clockwise")
		#else:
		#velocity.x = ai_controller.move.x
		#velocity.z = ai_controller.move.y
		#camera_fixed_at(ai_controller.camera_direction)
		
		move_and_slide()
		return
	
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
