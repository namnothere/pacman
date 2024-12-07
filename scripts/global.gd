extends Node
var grid
var pellet_map
var target_pellet: Node3D
var player_pos: Vector2
var visited: Array = []
var is_ai_control: bool = false
var is_algo: bool = false
var MAP_SIZE: int = 5
var is_topdown_active: bool = true
var is_four_wall_only: bool = false
