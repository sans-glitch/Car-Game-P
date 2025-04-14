extends RayCast3D

#@onready var car : RigidBody3D = get_parent().get_parent()
@onready var car: RigidBody3D = $"../.."

@onready var wheel := $WheelMesh
var previous_spring_length: float = 0.0

@export var is_front_wheel : bool 

var susp_force : Vector3
var grip : float

func _ready() -> void:
	add_exception(car)
	$WheelMesh/StaticBody3D.add_collision_exception_with(car)
	target_position = Vector3(0, -(car.suspension_rest_dist + car.wheel_radius), 0)

func _physics_process(delta: float) -> void:
	
	grip = 0
	
	if is_colliding():
		var collision_point = get_collision_point()
		suspension(delta, collision_point)
		if not Input.is_action_pressed("brake"):
			acceleration(collision_point)
		
		#apply_z_force(collision_point)
		apply_x_force(delta, collision_point)
		apply_friction(collision_point, (car.mass / 25))
		set_wheel_position(to_local(collision_point).y + car.wheel_radius)
	else:
		set_wheel_position(-car.suspension_rest_dist)
		
	#if Input.is_action_pressed("brake"):
		#var collision_point = get_collision_point()
		#apply_friction(collision_point, (car.mass)/25)
	
func apply_x_force(delta, collision_point):
	var dir: Vector3 = global_basis.x
	#var tire_world_vel: Vector3 = get_point_velocity(global_position)
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var tire_world_vel: Vector3 = state.get_velocity_at_local_position(global_position - car.global_position)
	var lateral_vel: float = dir.dot(tire_world_vel)
	
	#var grip = car.rear_tire_grip
	#if is_front_wheel:
		#grip = car.front_tire_grip
		#
	#grip = susp_force.length()/car.spring_strength
	
	var desired_vel_change: float = -lateral_vel * grip
	var x_force = desired_vel_change / delta / 1
	
	car.apply_force(dir * x_force, collision_point - car.global_position)
	
	if car.debug:
		DebugDraw3D.draw_arrow(global_position, global_position + (dir * x_force/200), Color.RED, 0.1, true)
		
func apply_z_force(collision_point):
	var dir : Vector3 = global_basis.z 
	#var tire_world_vel: Vector3 = get_point_velocity(global_position)
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var tire_world_vel: Vector3 = state.get_velocity_at_local_position(global_position - car.global_position)
	var z_force = dir.dot(tire_world_vel) * car.mass / 5 # COULD BE TIRE FRICTION AND AIR RESISTANCE
	
	car.apply_force(-dir * z_force, collision_point - car.global_position)
	
func apply_friction(collision_point, coefficient):
	var state := PhysicsServer3D.body_get_direct_state(car.get_rid())
	var tire_world_vel: Vector3 = state.get_velocity_at_local_position(global_position - car.global_position)
	var friction = -tire_world_vel * grip * coefficient
	# General friction
	car.apply_force(friction, collision_point - car.global_position)
	var sideways_motion = global_basis.x
	var sideways_force = sideways_motion * sideways_motion.dot(tire_world_vel)
	# Additional friction on sliding directions
	car.apply_force(sideways_force, collision_point - car.global_position)
	#
	if car.debug:
		DebugDraw3D.draw_arrow(collision_point, collision_point + friction, Color.SADDLE_BROWN, 0.1, true)
	#pass
	
func set_wheel_position(new_y_position: float):
	wheel.position.y = lerp(wheel.position.y, new_y_position, 0.6)
	
func get_point_velocity(point: Vector3):
	return car.linear_velocity + car.angular_velocity.cross(point - car.global_position)
	
	
func acceleration(collision_point):
	#if is_front_wheel:
		#return
	var accel_dir = -global_basis.z
	
	var torque = car.accel_input * car.engine_power * grip

	var point = Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	
	car.apply_force(accel_dir * torque, point - car.global_position)
	
	if car.debug:
		DebugDraw3D.draw_arrow(point, point + (accel_dir * torque / 200), Color.BLUE, 0.1, true)
func suspension(delta, collision_point):
	#Direction of force
	var susp_dir = global_basis.y
	
	var raycast_origin = global_position
	var raycast_dest = collision_point
	var distance = raycast_dest.distance_to(raycast_origin)
	
	#var contact = raycast_dest - car.global_position
	
	var spring_length = clamp(distance - car.wheel_radius, 0, car.suspension_rest_dist)
	
	var spring_force = car.spring_strength * (car.suspension_rest_dist - spring_length)
	
	var spring_velocity = (previous_spring_length - spring_length) / delta
	
	var damper_force = car.spring_damper * spring_velocity
	
	var suspension_force = susp_dir * (spring_force + damper_force)
	susp_force = suspension_force
	#if is_front_wheel:
		#print(spring_length)
	
	grip = ((car.suspension_rest_dist - spring_length) + damper_force/car.spring_strength) * 5 + 2
	#print(grip)
	previous_spring_length = spring_length
	
	var point = Vector3(raycast_dest.x, raycast_dest.y + car.wheel_radius, raycast_dest.z)
	#$WheelMesh.global_position = point
	car.apply_force(suspension_force, point - car.global_position)
	
	if car.debug:
		#DebugDraw3D.draw_arrow(global_position, to_global(position + Vector3(-position.x, (suspension_force.y / 2000), -position.z)), Color.GREEN, 0.1, true)
		DebugDraw3D.draw_arrow(global_position, global_position + (suspension_force / 2000), Color.GREEN, 0.1, true)
