extends RigidBody3D

@export var suspension_rest_dist : float = 0.5
@export var spring_strength : float = 10
@export var spring_damper : float = 1
@export var wheel_radius : float = 0.33

@export var debug : bool = false
@export var engine_power : float

var accel_input

@export var steering_angle : float = 30
@export var front_tire_grip : float = 2
@export var rear_tire_grip : float = 2
@export var min_grip : float = 2
@export var grip_mult : float = 5
@export var friction_denom : float = 25
@export var awd = false
var steering_input

func _process(delta: float) -> void:
	accel_input = Input.get_axis("reverse", "accelerate")
	
	steering_input = Input.get_axis("turn_right", "turn_left")
	
	var steering_rotation = steering_input * steering_angle
	
	var fl_wheel = $Wheels/FLWheel
	var fr_wheel = $Wheels/FRWheel
	
	if steering_rotation != 0:
		var angle = clamp(fl_wheel.rotation.y + steering_rotation, -steering_angle, steering_angle)
		var new_rotation = angle * delta
		
		fl_wheel.rotation.y = lerp(fl_wheel.rotation.y, new_rotation, 0.3)
		fr_wheel.rotation.y = lerp(fr_wheel.rotation.y, new_rotation, 0.3)
	else:
		fl_wheel.rotation.y = lerp(fl_wheel.rotation.y, 0.0, 0.3)
		fr_wheel.rotation.y = lerp(fr_wheel.rotation.y, 0.0, 0.3)

func _physics_process(delta: float) -> void:
	#downforce()
	pass

func downforce():
	var forward_vel = max(0, -(linear_velocity * global_basis).z)
	#var forward_vel = 10
	var force = (Vector3(0, -forward_vel/10, 0)).rotated(Vector3(1, 0, 0), global_rotation.x).rotated(Vector3(0, 0, 1), global_rotation.z).rotated(Vector3(0, 1, 0), global_rotation.y)
	#var force = (Vector3(0, -forward_vel/10, 0)) * global_transform
	var downforce_pos = Vector3(0, 2, 1)
	
	apply_force(force, downforce_pos)
	#print(forward_vel)
	#print(global_rotation.z)
	if debug:
		DebugDraw3D.draw_arrow(to_global(downforce_pos), to_global(downforce_pos) + force, Color.VIOLET, 0.1, true)

	
