extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("found_solution", _on_found_solution)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_found_solution(solution: Array):
	$Solution.set_text(", ".join(solution))
