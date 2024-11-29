extends CanvasLayer

@onready var score_label: Label = $MarginContainer/VSplitContainer/ScoreLabel
@onready var optionBtn: OptionButton = $OptionContainer/VSplitContainer/OptionButton
var score: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("found_solution", _on_found_solution)
	Signals.connect("received_reward", _on_received_reward)
	Signals.connect("penalty", _on_penalty)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_found_solution(solution: Array):
	$Solution.set_text(", ".join(solution))

func _get_score_label():
	return score_label.text

func _set_score_label(newScore: String):
	score = int(newScore)
	score_label.text = str(score)

func _on_received_reward(point: int):
	print("Collected ", point)
	score += point
	score_label.text = str(score)
	
func _on_penalty():
	score -= 1 
	score_label.text = str(score)


func _on_start_button_pressed() -> void:
	print("Chosing", optionBtn.get_selected_id())
	Solver._get_solution(Global.grid, Global.pellet_map, optionBtn.get_selected_id())

	pass # Replace with function body.
