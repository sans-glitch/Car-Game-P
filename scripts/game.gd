extends Node3D

var city_grid : Array

func _ready() -> void:
	generate_maze(5, 5)

func _input(event: InputEvent) -> void:
	if event.is_action("restart"):
		get_tree().reload_current_scene()

func generate_maze(width: int, height: int) -> void:
	# Generates empty grid
	for r in height:
		city_grid.append([])
		for c in width:
			city_grid[r].append([])
			
	
			
			
