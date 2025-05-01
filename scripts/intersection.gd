extends Node
class_name Intersection

## Right, Up, Left, Down
var connections : Array[bool]
var been_visited = false
var coordinates : Vector2i
const intersection_packed_scene : PackedScene = preload("res://scenes/intersection.tscn")

func _ready() -> void:
	pass
	
static func new_tile(coordinates : Vector2i):
	var tile = intersection_packed_scene.instantiate()
	tile.coordinates = coordinates
	tile.reset_connections()
	return tile
	
func reset_connections():
	connections = [false, false, false, false]

func gen_tile(tile_map : Array):
	been_visited = true
	var neighbors = get_neighbors(tile_map)
	while neighbors.size() > 0:
		var rand_index = randi_range(0, neighbors.size() - 1)
		if neighbors[rand_index].been_visited == false:
			var relation = neighbors[rand_index].coordinates - coordinates
			prints(neighbors[rand_index].coordinates, coordinates, "relation:", relation)
			var index = direction_to_index(relation)
			create_connection(index)
			neighbors[rand_index].gen_tile(tile_map)
		neighbors.remove_at(rand_index)

func set_only_connection(index):
	connections = [false, false, false, false]
	connections[index] = true

func create_connection(index):
	print("index :" + str(index))
	connections[index] = true

func get_neighbors(tile_map : Array):
	var neighbors = []
	for i in 3:
		print(i, index_to_direction(i))
		var new_coords = coordinates + index_to_direction(i)
		prints("new coords", new_coords)
		if is_in_board(tile_map, new_coords):
			neighbors.append(tile_map[new_coords.y][new_coords.x])
	return neighbors


static func is_in_board(tile_map : Array, coords : Vector2i):
	return coords.x >= 0 and coords.x < tile_map[0].size() and coords.y >= 0 and coords.y < tile_map.size()

static func index_to_direction(index):
	if index == 0:
		return Vector2i(1, 0)
	if index == 1:
		return Vector2i(0, -1)
	if index == 2:
		return Vector2i(-1, 0)
	if index == 3:
		return Vector2i(0, 1)

static func direction_to_index(direction : Vector2i):
	#for i in 3:
		#if index_to_direction(i) == direction:
			#return i
	if direction == Vector2i(1, 0):
		return 0
	if direction == Vector2i(0, -1):
		return 1
	if direction == Vector2i(-1, 0):
		return 2
	if direction == Vector2i(0, 1):
		return 3

func side_connections_to_string() -> String:
	if connections[2]:
		return (" - ")
	else:
		return (" | ")
	if connections[0]:
		return (" - ")
	else:
		return (" | ")

func vertical_connections_to_string() -> String:
	if connections[1]:
		return (" | ")
	else:
		return (" - ")
	if connections[3]:
		return (" | ")
	else:
		return (" - ")
