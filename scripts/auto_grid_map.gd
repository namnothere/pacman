extends Node3D

var grid: Array = []
var center_x: int
var center_y: int
var DIRECTIONS = [Vector2(0, -2), Vector2(0, 2), Vector2(-2, 0), Vector2(2, 0)]

const FLOOR: int = -1
const WALL: int = 0
const PELLET: int = 1
const PLAYER: int = 2
const CHARACTER_SCALE: int = 4
var tween: Tween

@export var MAP_SIZE: int = 5
@export var is_auto_map: bool = true
@export var PELLET_SPAWN_RATIO: float = 0.04
@export var MIN_PELLET_SPAWN: int = 1

@onready var grid_map: GridMap = $GridMap_Maze
@onready var player: CharacterBody3D = $player
@onready var topdowncamera: Camera3D = $TopDownCamera
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("found_solution", _on_found_solution)
	tween  = get_tree().create_tween()
	if is_auto_map:
		grid_map.clear()
		init_map()
		dfs_maze_generate()
		generate_grid()
		var pellet_map = spawn_pellets()
		spawn_player_at_random()

		Solver._get_solution(grid, pellet_map)
		
	if topdowncamera.current == true:
		player.scale = Vector3(CHARACTER_SCALE, CHARACTER_SCALE, CHARACTER_SCALE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func init_map():
	for i in range(MAP_SIZE):
		var _row: Array = []
		_row.resize(MAP_SIZE)
		_row.fill(WALL)
		grid.append(_row)

	center_x = MAP_SIZE / 2 + 1
	center_y = MAP_SIZE / 2 + 1

	grid[center_y][center_x] = 0

func generate_grid():
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			var logical_x = x - center_x
			var logical_y = y - center_y

			if grid[y][x] == WALL:
				var logical_vector = Vector3i(logical_x, 0, logical_y)
				grid_map.set_cell_item(logical_vector, WALL)

func dfs_maze_generate(start_x: int = 1, start_y: int = 1):
	grid[start_y][start_x] = FLOOR
	#grid[start_y][start_x + 1] = 0
	var stack = [Vector2(start_y, start_x)]

	while stack.size() > 0:
		var current: Vector2 = stack[stack.size() - 1]
		var current_x: int = current.x
		var current_y: int = current.y
		
		var neighbors = []
		for direction in DIRECTIONS:
			var nx = current_x + direction.x
			var ny = current_y + direction.y
			
			if is_valid_move(nx, ny):
				var between_x = current_x + direction.x / 2
				var between_y = current_y + direction.y / 2
				if grid[ny][nx] == WALL and grid[between_y][between_x] == WALL:
					neighbors.append(Vector2(nx, ny))

		if neighbors.size() > 0:
			var next = neighbors[randi_range(0, neighbors.size() - 1)]
			var next_x = next.x
			var next_y = next.y

			var between_x = current_x + (next_x - current_x) / 2
			var between_y = current_y + (next_y - current_y) / 2

			grid[between_y][between_x] = FLOOR
			grid[next_y][next_x] = FLOOR
			stack.append(next)
		else:
			stack.pop_back()

func is_valid_move(x: int, y: int):
	return x >= 0 and x < MAP_SIZE and y > 0 and y < MAP_SIZE and grid[y][x] == WALL

func choose_spawn_position():
	var zero_cells = []

	for y in range(grid.size()):
		for x in range(grid.size()):
			if grid[y][x] == FLOOR:
				zero_cells.append(Vector2(x, y))
	if zero_cells.size() == 0:
		return null

	return zero_cells[randi_range(0, zero_cells.size() - 1)]
	
func spawn_player_at_random():
	var start_pos: Vector2 = choose_spawn_position()
	
	grid[start_pos.y][start_pos.x] = PLAYER
	
	print("Choose cell: ", start_pos.x, ", " , start_pos.y)
	
	var logical_x = start_pos.x - center_x
	var logical_y = start_pos.y - center_y

	var logical_vector = Vector3i(logical_x, 0, logical_y)
	grid_map.set_cell_item(logical_vector, PLAYER)
	
	var cells = grid_map.get_used_cells_by_item(PLAYER)
	if cells.size() > 0:
		var grid_cell = cells[0]
		var world_position = grid_map.map_to_local(grid_cell)
		player.global_transform.origin = world_position
		grid_map.set_cell_item(grid_cell, -1)

func spawn_pellets():
	var empty_cells = []
	var pellet_map = []
	
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == FLOOR:
				empty_cells.append(Vector2(x, y))

	empty_cells.shuffle()

	var num_pellets = max(int(empty_cells.size() * PELLET_SPAWN_RATIO), MIN_PELLET_SPAWN)
	for i in range(num_pellets):
		var pellet_cell = empty_cells[i]
		grid[pellet_cell.y][pellet_cell.x] = PELLET
		pellet_map.append([pellet_cell.y, pellet_cell.x])

		var logical_x = pellet_cell.x - center_x
		var logical_y = pellet_cell.y - center_y

		grid_map.set_cell_item(Vector3(logical_x, 0, logical_y), PELLET)
		
	print("Spawned pellets in ", num_pellets, " cells out of ", empty_cells.size())
	return pellet_map

func move_to_next_step(steps_array):
	#var steps_array = [[9,0]]
	if steps_array.size() > 0:
		var current_step = steps_array[0]
		
		# Convert to world position
		var local_position = grid_map.map_to_local(Vector3(current_step[0], 0, current_step[1]))
		var world_position = grid_map.to_global(local_position)
		
		tween.tween_property(player, "global_transform/origin", world_position, 1.0).as_relative().set_ease(Tween.EASE_IN_OUT);
		
		player.global_transform.origin = world_position
		
		steps_array.remove_at(0)
		
		move_to_next_step(steps_array)
	else:
		print("Character has reached the goal!")

func _on_found_solution(solution):
	#move_to_next_step(solution)
	pass
