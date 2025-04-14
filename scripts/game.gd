extends Node3D

func _input(event: InputEvent) -> void:
	if event.is_action("restart"):
		get_tree().reload_current_scene()
