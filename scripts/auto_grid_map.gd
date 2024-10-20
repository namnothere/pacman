extends Node3D

#var grid = [
	#[1, 1, 1, 1, 1, 1, 1],
	#[1, 0, 1, 0, 1, 1, 1],
	#[1, 1, 0, 0, 1, 0, 1],
	#[1, 1, 1, 1, 0, 1, 1],
	#[1, 1, 0, 1, 1, 0, 1],
	#[1, 0, 1, 0, 1, 1, 1],
	#[1, 1, 1, 1, 1, 1, 1]
#]

var grid: Array = []
var center_x: int
var center_y: int

@export var MAP_SIZE: int = 21
@onready var grid_map: GridMap = $GridMap_Maze

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grid_map.clear()
	init_map()
	generate_grid()
	var cells = grid_map.get_used_cells_by_item(0)
	print(cells)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func init_map():
	for i in range(MAP_SIZE):
		grid.append([])
		for j in range(MAP_SIZE):
			grid[i].append(0)
			
	center_x = MAP_SIZE / 2
	center_y = MAP_SIZE / 2

	grid[center_y][center_x] = 1

	print("Center of the array is mapped to (0, 0)")
	
	for row in grid:
		print(row)
	
func generate_grid():
	for y in range(MAP_SIZE):
		for x in range(MAP_SIZE):
			var logical_x = x - center_x
			var logical_y = y - center_y

			if y == 0 or y == MAP_SIZE - 1 or x == 0 or x == MAP_SIZE - 1:
				grid[y][x] = 1
				var logical_vector = Vector3i(logical_x, 0, logical_y)
				grid_map.set_cell_item(logical_vector, 0)
			else:
				grid[y][x] = 0
				
			print("Array index: [", x, ",", y, "] -> Logical coordinates: (", logical_x, ",", logical_y, ")")
