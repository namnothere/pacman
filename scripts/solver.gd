extends Node

const ENDPOINT_URL: String = "http://127.0.0.1:5005"
#const ENDPOINT_URL: String = "https://webhook.site/14e457f2-547d-4e58-a28d-fbfe6c573683"
var http_request: HTTPRequest

enum {BFS, DFS, ID, UCS, HC, GBFS}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request = HTTPRequest.new()
	http_request.use_threads = true
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _get_solution(tile_map, pellet_map, algo: int = GBFS):
	var body = JSON.stringify({"tile_map": tile_map, "pellet_map": pellet_map, "algo": algo, "start_position": [0, 0]})
	print(body)
	await http_request.request(ENDPOINT_URL + "/solve", [], HTTPClient.METHOD_POST, body)
	#await http_request.request(ENDPOINT_URL, [], HTTPClient.METHOD_POST, body)
	
func _http_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if "solution" not in json:
		return
	print("Solution found")
	Signals.emit_signal("found_solution", json["solution"])
