extends Node3D


@export var platform_scene: PackedScene = preload("res://Platform.tscn")
@export var player: Node3D

var platforms: Array = []
var last_z: float = 0.0
var last_y: float = 0.0
var last_x: float = 0.0
var time_since_last_spawn: float = 0.0
var last_width: float = 3.0

func _ready():
	spawn_starting_platform()  # First, spawn the starting platform

func _process(delta):
	var player_z = player.global_transform.origin.z
	var furthest_platform_z = platforms.back().global_transform.origin.z if platforms.size() > 0 else 0
	
	# Ensure 50 units ahead are always filled with platforms
	while furthest_platform_z > player_z - Globals.player_lookahead:
		spawn_platform()
		furthest_platform_z = platforms.back().global_transform.origin.z

	# Recycle platforms as before
	for platform in platforms:
		if platform.global_transform.origin.z > player_z + 10:
			platform.queue_free()
			platforms.erase(platform)
			
func spawn_starting_platform():
	# Create a 3-wide starting platform at the center
	var starting_platform = platform_scene.instantiate()
	
	var position = Vector3(0, 0, 0)  # Centered at lane 0, at z = 0
	starting_platform.global_transform.origin = position
	starting_platform.scale = Vector3(3, Globals.platform_height, Globals.platform_base_length)  # Width 3, height fixed, length fixed
	
	# Add platform to the scene
	add_child(starting_platform)
	platforms.append(starting_platform)
	
	# Update last_z and last_y to continue spawning from this point
	last_z = position.z
	last_y = position.y
	last_x = position.x

func spawn_platform():
	var new_platform = platform_scene.instantiate()
	# Y axis (height)
	
	var choices = [Globals.platform_height_diff, -Globals.platform_height_diff, 0]
	var height_offset = choices[randi() % choices.size()]
	var new_y = clamp(last_y + height_offset, Globals.min_y, Globals.max_y)
	
	# X axis (sideways)
	var width = randi_range(2, 5)  # Random width between 2 and 5
	
	# Calculate the current platform's lane range
	var current_min_lane = floor(last_x - last_width / 2)
	var current_max_lane = ceil(last_x + last_width / 2)
	
	# Calculate overlap lanes
	var overlap_min_lane = max(current_min_lane, Globals.min_x)
	var overlap_max_lane = min(current_max_lane, Globals.max_x)
	
	var max_offset = Globals.max_x - width / 2 - 0.5  # Adjust for 0.5 offset
	var min_offset = Globals.min_x + width / 2 + 0.5  # Adjust for 0.5 offset
	
	# Choose a lane in the overlap range
	var overlap_lane = randi_range(overlap_min_lane, overlap_max_lane)
	
	# Calculate the new platform's center (new_x) based on overlap lane
	var new_x = overlap_lane
	if width % 2 == 0:  # Add 0.5 offset for even-width platforms
		new_x += 0.5
	
	# Ensure the platform stays within bounds
	new_x = clamp(new_x, Globals.min_x + width / 2, Globals.max_x - width / 2)

	var new_position = Vector3(new_x, new_y, last_z - Globals.platform_gap - Globals.platform_base_length)
	new_platform.global_transform.origin = new_position

	# Set the scale of the platform root node directly in code
	new_platform.scale = Vector3(width, Globals.platform_height, Globals.platform_base_length)  # Width, height (fixed), length (fixed)

	add_child(new_platform)
	
	platforms.append(new_platform)
	last_z = new_position.z
	last_y = new_position.y
	last_x = new_position.x
	last_width = width
