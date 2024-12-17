extends Node3D

@export var player: Node3D  # Reference to the player
@export var radius: float = 7.0  # Distance from the player
@export var min_pitch: float = -15.0  # Minimum vertical angle
@export var max_pitch: float = 60.0  # Maximum vertical angle
@export var min_yaw: float = -55.0  # Minimum vertical angle
@export var max_yaw: float = 55.0  # Maximum vertical angle
@export var sensitivity: float = 0.1  # Mouse sensitivity for movement

var yaw: float = 0.0  # Horizontal angle
var pitch: float = 0.0  # Vertical angle

func _ready():
	# Set initial camera position
	update_camera_position()

func _process(delta):
	if Input.is_action_pressed("camera_toggle"):  # Custom action, bind it to a key
		update_camera_position()

func _input(event):
	if event is InputEventMouseMotion:
		# Update yaw and pitch based on mouse movement
		yaw -= event.relative.x * sensitivity
		pitch -= event.relative.y * sensitivity

		# Clamp pitch to avoid flipping
		pitch = clamp(pitch, min_pitch, max_pitch)
		yaw = clamp(yaw, min_yaw, max_yaw)

		# Update camera position
		update_camera_position()

func update_camera_position():
	# Convert spherical coordinates to cartesian coordinates
	var x = radius * cos(deg_to_rad(pitch)) * sin(deg_to_rad(yaw))
	var y = radius * sin(deg_to_rad(pitch))
	var z = radius * cos(deg_to_rad(pitch)) * cos(deg_to_rad(yaw))

	# Set the camera's position relative to the player
	global_transform.origin = player.global_transform.origin + Vector3(x, y, z)

	# Make the camera look at the player
	look_at(player.global_transform.origin, Vector3.UP)
