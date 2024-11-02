extends Node3D

var grid: Array = []
var center_x: int
var center_y: int
var DIRECTIONS = [Vector2(0, -2), Vector2(0, 2), Vector2(-2, 0), Vector2(2, 0)]

const FLOOR: int = 0
const WALL: int = 1
@export var MAP_SIZE: int = 25
@onready var grid_map: GridMap = $GridMap_Maze

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_map.clear()
	init_map()
	dfs_maze_generate()
	generate_grid()
	#var cells = grid_map.get_used_cells_by_item(0)

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

			if grid[y][x] == 1:
				var logical_vector = Vector3i(logical_x, 0, logical_y)
				grid_map.set_cell_item(logical_vector, 0)

func dfs_maze_generate(start_x: int = 0, start_y: int = 0):
	grid[start_x][start_y] = 0
	var stack = [Vector2(start_x, start_y)]

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
				if grid[ny][nx] == 1 and grid[between_y][between_x] == 1:
					neighbors.append(Vector2(nx, ny))
			
		if neighbors.size() > 0:
			var next = neighbors[randi_range(0, neighbors.size() - 1)]
			var next_x = next.x
			var next_y = next.y

			var between_x = current_x + (next_x - current_x) / 2
			var between_y = current_y + (next_y - current_y) / 2

			grid[between_y][between_x] = 0
			grid[next_y][next_x] = 0
			stack.append(next)
		else:
			stack.pop_back()

func is_valid_move(x: int, y: int):
	return x >= 0 and x < MAP_SIZE and y >= 0 and y < MAP_SIZE and grid[y][x] == 1
