extends CharacterBody3D

@onready var score_label: Label

# Fixed jump and gravity settings
var gravity: float = 9.8  # Constant gravity value (can be adjusted for feel)
var jump_force: float = 10.0  # Constant jump force value

# Sideways movement settings
var target_lane: int = 0  # Current target lane (center is 0)
var changing_lane: bool = false
var platforms_cleared = {}

func _ready():
	# Set the player's position to the top center of the starting platform
	global_transform.origin = Vector3(0, Globals.platform_height + Globals.player_size, 0)  # X = 0, Y slightly above platform, Z near the platform center
	$CharacterCollision.scale = Vector3(Globals.player_size,Globals.player_size,Globals.player_size)

	score_label = get_node("../UI/Score/ScoreLabel")
	update_score()

	# Freeze the game by setting the `process` and `physics_process` to false
	set_physics_process(false)
	set_process(false)

	# Show the start menu
	show_start_menu()
	
func update_score():
	Globals.score = platforms_cleared.size()
	score_label.text = "Score: %d" % Globals.score
	if Globals.score % 10 == 0:
		if Globals.game_speed < 5:
			Globals.game_speed += 0.25
		if Globals.platform_gap < 3:
			Globals.platform_gap += 0.25
	
		print("Score: ", Globals.score)
		print("Speed: ", Globals.game_speed)
		print("Gap: ", Globals.platform_gap)
		
	
func reset():
	target_lane = 0
	changing_lane = false
	platforms_cleared = {}
	_ready()
	
func show_start_menu():
	var start_label = get_node("../UI/Start/StartLabel")
	start_label.visible = true

func hide_start_menu():
	var start_label = get_node("../UI/Start/StartLabel")
	start_label.visible = false

func start_game():
	Globals.game_started = true
	set_physics_process(true)
	set_process(true)
	hide_start_menu()

func _physics_process(delta):
	if not Globals.game_started:
		return  # Do nothing if the game hasn't started
		
	for i in get_slide_collision_count():
		var platform_id = get_slide_collision(i).get_collider_id()
		platforms_cleared[platform_id] = null
		
	if Globals.score < platforms_cleared.size():
		update_score()
	
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
	# Start the game when space is pressed
	if not Globals.game_started and Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is mapped to Space by default
		start_game()
	
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
			
	
