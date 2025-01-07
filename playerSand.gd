extends CharacterBody3D

@export var cameras: Array[Camera3D]  # Drag and drop your cameras here
var current_camera_index: int = 0

@onready var score_label: Label
@onready var wind_particles: GPUParticles3D  # Partículas para mostrar el viento
var percentage: float = 0.0

# Fixed jump and gravity settings
var gravity: float = 9.8  # Constant gravity value (can be adjusted for feel)
var jump_force: float = 10.0  # Constant jump force value
var wind_force: float = 2.0  # Intensidad del viento
var wind_direction: int = 0  # -1 para izquierda, 1 para derecha
# Sideways movement settings
var target_lane: int = 0  # Current target lane (center is 0)
var changing_lane: bool = false


func _ready():
	# Set the player's position to the top center of the starting platform
	global_transform.origin = Vector3(0, Globals.platform_height + Globals.player_size, 0)  # X = 0, Y slightly above platform, Z near the platform center
	$CharacterCollision.scale = Vector3(Globals.player_size,Globals.player_size,Globals.player_size)
	wind_particles = $SandStormParticles  # Nodo GPUParticles3D
	score_label = get_node("../UI/Score/ScoreLabel")
	update_score()

	# Freeze the game by setting the `process` and `physics_process` to false
	set_physics_process(false)
	set_process(false)
	
	# Ensure only one camera is active
	for i in range(cameras.size()):
		cameras[i].current = (i == current_camera_index)
	
	if randi() % 2 == 0:
		wind_direction = 1
	else:
		wind_direction= -1
	start_game()
	
func update_score():
	Globals.score = Globals.platforms_cleared.size()
	if Globals.platforms_existed.size() > 0:
		var existed = float(Globals.platforms_existed.size())
		percentage = (Globals.score / existed) * 100
	
	# Update the text to show score and stats on separate lines
	score_label.text = "Score: %d/%d (%.2f%%)\n" % [Globals.platforms_cleared.size(), Globals.platforms_existed.size(), percentage]
	score_label.text += "Speed: %.2f/%.2f\n" % [Globals.game_speed, Globals.max_game_speed]
	score_label.text += "Gap: %.2f/%.2f\n" % [Globals.platform_gap, Globals.max_platform_gap]
	score_label.text += "Height Difference: %.2f/%.2f\n" % [Globals.platform_height_diff, Globals.max_height_diff]
	score_label.text += "Length: %.2f/%.2f\n" % [Globals.platform_base_length, Globals.max_base_len]
	score_label.text += "Camera: %s" % cameras[current_camera_index].name	

	# Update game stats when score reaches multiples of 10
	if Globals.score % 10 == 0 and Globals.score != 0:
		if Globals.game_speed < Globals.max_game_speed:
			Globals.game_speed += 0.50
		if Globals.platform_gap < Globals.max_platform_gap:
			Globals.platform_gap += 0.25
		if Globals.platform_base_length > Globals.max_base_len:
			Globals.platform_base_length -= 0.25
		if Globals.platform_height_diff < Globals.max_height_diff:
			Globals.platform_height_diff += 0.1

func reset():
	target_lane = 0
	percentage = 0.0
	changing_lane = false
	_ready()

func start_game():
	Globals.game_started = true
	set_physics_process(true)
	set_process(true)
	
func toggle_camera():
	# Deactivate the current camera
	cameras[current_camera_index].current = false

	# Switch to the next camera
	current_camera_index = (current_camera_index + 1) % cameras.size()

	# Activate the new camera
	cameras[current_camera_index].current = true

func _physics_process(delta):

	for i in get_slide_collision_count():
		var platform_id = get_slide_collision(i).get_collider_id()
		Globals.platforms_cleared[platform_id] = null
		
	if Globals.score < Globals.platforms_cleared.size():
		update_score()
	
	# Determine the current game speed
	var current_speed = Globals.game_speed
	if Input.is_action_pressed("ui_accept"):  # "ui_accept" is mapped to the space bar by default
		current_speed *= 3  # Double the speed when space bar is pressed
	velocity.z = -current_speed
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
	velocity.y = jump_force
	apply_wind_effect()  # Apply the calculated jump force
	call_deferred("start_animation")
	
func start_animation():
	$Animation.play("jump")
	
func perform_drop():
	# Ensure the player is airborne before they can drop down
	if not is_on_floor():  # Only drop if the player is not on the floor
		velocity.y = -gravity * 1.5  # Apply a small downward force when dropping

func apply_wind_effect():
	# Selecciona una dirección aleatoria para el viento: -1 (izquierda) o 1 (derecha)

	# Aplica el viento a la velocidad horizontal
	velocity.x += wind_direction * wind_force

	# Actualiza la dirección de las partículas
	var particle_direction = Vector3(wind_direction, 0, 0.3)
	var particles_material = $SandStormParticles.process_material
	particles_material.direction = particle_direction
	$SandStormParticles.emitting = true
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
			
	if Input.is_action_pressed("toggle_camera"):
		toggle_camera()
		update_score()
