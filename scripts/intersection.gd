extends Node
class_name Intersection

var connections : Array[bool]
var been_visited = false
var coordinates : Vector2i

func _ready() -> void:
	# Right, Up, Left, Down
	connections = [false, false, false, false]
	
func set_only_connection(index):
	connections = [false, false, false, false]
	connections[index] = true

func create_connection(index):
	connections[index] = true
	
func get_neighbors(tile_map : Array):
	var neighbors = []
	for i in 3:
		var new_coords = coordinates + index_to_direction(i)
		if is_in_board(tile_map, new_coords):
			neighbors.append(tile_map[new_coords.y][new_coords.x])
	return neighbors


static func is_in_board(tile_map : Array, coords : Vector2i):
	return coords.x < 0 or coords.x > tile_map[0].size() or coords.y < 0 or coords.y > tile_map.size()

static func index_to_direction(index):
	if index == 0:
		return Vector2i(1, 0)
	if index == 1:
		return Vector2i(0, -1)
	if index == 2:
		return Vector2i(-1, 0)
	if index == 3:
		return Vector2i(0, 1)
