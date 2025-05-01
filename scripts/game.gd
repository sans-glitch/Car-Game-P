extends Node3D

var city_grid : Array

func _ready() -> void:
	generate_maze(10, 10)

func _input(event: InputEvent) -> void:
	if event.is_action("restart"):
		get_tree().reload_current_scene()

func generate_maze(width: int, height: int) -> void:
	# Generates empty grid
	for r in height:
		city_grid.append([])
		for c in width:
			var new_tile = Intersection.new_tile(Vector2i(c, r))
			add_child(new_tile)
			city_grid[r].append(new_tile)
	
	city_grid[randi_range(0, height-1)][randi_range(0, width-1)].gen_tile(city_grid)
			
	for r in height:
		var hori_string = ""
		var vert_string = " "
		for c in width:
			hori_string += city_grid[r][c].side_connections_to_string()
			vert_string += city_grid[r][c].vertical_connections_to_string()
		print(hori_string)
		print(vert_string)
		print("")
			
			
