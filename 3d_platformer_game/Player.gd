extends CharacterBody3D

# Fixed jump and gravity settings
var gravity: float = 9.8  # Constant gravity value (can be adjusted for feel)
var jump_force: float = 10.0  # Constant jump force value

# Sideways movement settings
var target_lane: int = 0  # Current target lane (center is 0)
var changing_lane: bool = false

func _ready():
	# Set the player's position to the top center of the starting platform
	global_transform.origin = Vector3(0, Globals.platform_height/2 + Globals.player_size/2, 0)  # X = 0, Y slightly above platform, Z near the platform center
	$Character.scale = Vector3(Globals.player_size,Globals.player_size,Globals.player_size)
	$CharacterCollision.scale = Vector3(Globals.player_size*0.99,Globals.player_size*0.99,Globals.player_size*0.99)

func _physics_process(delta):
	# Forward movement
	velocity.z = -Globals.game_speed

	# Calculate the target X position based on the lane
	var target_x = target_lane
	var curr_x = global_transform.origin.x

	if abs(curr_x - target_x) < 0.1:  # Close enough to snap
		velocity.x = 0.0
		global_transform.origin.x = target_x  # Snap to lane to avoid jittering
		changing_lane = false
	else:
		# Smoothly transition to the target lane
		velocity.x = (target_x - curr_x) * 20.0  # Adjust the multiplier for speed
		changing_lane = true
		
	# If the player is airborne, apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta  # Apply gravity when in the air
	else:
		# If on the floor, allow jumping again and reset velocity.y to 0 only if landing
		if velocity.y < 0:
			velocity.y = 0  # Reset Y velocity when on the floor

	move_and_slide()

func perform_jump():
	velocity.y = jump_force  # Apply the calculated jump force
	
func perform_drop():
	# Ensure the player is airborne before they can drop down
	if not is_on_floor():  # Only drop if the player is not on the floor
		velocity.y = -gravity * 1.5  # Apply a small downward force when dropping

func _input(event):
	# Handle jump input
	if Input.is_action_just_pressed("ui_up"):  # Change "ui_up" to whatever jump action you define
		if is_on_floor():  # Perform jump if on the floor
			perform_jump()

	# Handle drop input (for example, press a "down" key to drop down)
	if Input.is_action_just_pressed("ui_down"):  # Change "ui_down" to the key for dropping
		perform_drop()
	
	if not changing_lane:
		if Input.is_action_pressed("ui_left"):
			target_lane = clamp(target_lane-1, Globals.min_x, Globals.max_x)
		elif Input.is_action_pressed("ui_right"):
			target_lane = clamp(target_lane+1, Globals.min_x, Globals.max_x)
			
	
