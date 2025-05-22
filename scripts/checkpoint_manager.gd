extends Node

var next_checkpoint_num
var final_checkpoint_num

func _ready() -> void:
	next_checkpoint_num = 0
	
func initalize(num):
	final_checkpoint_num = max(final_checkpoint_num, num)

func reset():
	next_checkpoint_num = 0
	
func passed_through_checkpoint(checkpoint_num : int):
	if next_checkpoint_num == checkpoint_num:
		next_checkpoint_num += 1
