extends Node3D


@export var platform_scene: PackedScene = preload("res://LavaPlatform.tscn")
@export var modifier_scene: PackedScene = preload("res://LavaModifier.tscn")
@export var meteorite_scene: PackedScene = preload("res://Meteroid.tscn")  # Asegúrate de tener un Meteorite.tscn
@export var player: Node3D

var platforms: Array = []
var modifiers: Array = []
var meteorites: Array = []
var last_z: float = 0.0
var last_y: float = 0.0
var last_x: float = 0.0
var last_width: float = 3.0

func _ready():
	spawn_starting_platform()  # First, spawn the starting platform
	var meteor_timer = Timer.new()
	meteor_timer.wait_time = 5.0  # Cada 5 segundos
	meteor_timer.one_shot = false
	meteor_timer.connect("timeout", Callable(self, "_spawn_meteorite"))  # Usar Callable en Godot 4
	add_child(meteor_timer)
	meteor_timer.start()
	
func reset():
	for platform in platforms:
		if platform:
			platform.queue_free()
	
	for meteorite in meteorites:
		if meteorite:
			meteorite.queue_free()
	for modifier in modifiers:
		if modifier:
			modifier.queue_free()
	
	meteorites.clear()
	modifiers.clear()
	platforms.clear()
	last_z = 0.0
	last_y = 0.0
	last_x = 0.0
	last_width = 3.0
	for child in get_tree().get_root().get_children():
		if child is Node:
			child.set_process(false)
			child.set_physics_process(false)
	# Optionally, clear any delayed actions
	set_process(false)  # Temporarily stop `_process`


func _process(delta):
	if not platforms:  # Skip processing if reset is underway
		return
	
	var player_z = player.global_transform.origin.z
	var furthest_platform_z = platforms.back().global_transform.origin.z if platforms.size() > 0 else 0
	var platforms_to_remove = []
	var meteorites_to_remove = []
	# Ensure 50 units ahead are always filled with platforms
	while furthest_platform_z > player_z - Globals.player_lookahead:
		spawn_platform()
		furthest_platform_z = platforms.back().global_transform.origin.z

	# Recycle platforms as before
	for platform in platforms:
		if platform.global_transform.origin.z > player_z - (platform.scale.z * 1.5):
			Globals.platforms_existed[platform.get_instance_id()] = null
			
		if platform.global_transform.origin.z > player_z + 10:
			platform.queue_free()
			platforms.erase(platform)
	# Check for modifier collisions manually
	for modifier in modifiers:
		var modifier_global_pos =modifier.to_global(Vector3())
		var player_global_pos = player.to_global(Vector3())
		var distance = player_global_pos.distance_to(modifier_global_pos)
		#print("Distance to modifier: ", distance, " Player Z: ", player.global_transform.origin, " Modifier Z: ", child.global_transform.origin)
		if distance < 1.0:
			print("Player collided with a modifier!")
			modifier.queue_free()
			modifiers.erase(modifier)
	for platform in platforms:
		for meteorite in meteorites:
			if platform.global_transform.origin.distance_to(meteorite.global_transform.origin) < 0.5:
				print("Impacto detectado: Plataforma eliminada por meteorito.")
				platforms_to_remove.append(platform)
				meteorites_to_remove.append(meteorite)
				break  # No procesar más meteoritos para esta plataforma
	# Eliminar plataformas y meteoritos después de iterar
	for platform in platforms_to_remove:
		if platform.is_inside_tree():
			platforms.erase(platform)
			platform.queue_free()
	for meteorite in meteorites_to_remove:
			if meteorite.is_inside_tree():
				meteorites.erase(meteorite)
				meteorite.queue_free()
	#for meteorite in meteorites:
		#var target_platform = meteorite.get("target_platform")
		#print(target_platform)
		#if not target_platform:  # Saltar si no hay plataforma objetivo
			#continue
		#if meteorite.global_transform.origin.distance_to(target_platform.global_transform.origin) < 0.0:
			#print("Meteorito impactó la plataforma en: ", target_platform.global_transform.origin)
			#meteorite.queue_free()  # Eliminar el meteorito
			#meteorites.erase(meteorite)
			#target_platform.queue_free()  # Eliminar la plataforma
			#platforms.erase(target_platform)  # Quitarla del array
			# Quitar el meteorito del array
			#break  # Terminar el bucle para evitar errores al modificar la lista

	# Eliminar meteoritos que salieron del área visible
	#for meteorite in meteorites:
		#if meteorite.global_transform.origin.y < -10.0:  # Si cae demasiado
			#print("Meteorito fuera del área.")
			#meteorite.queue_free()
			#meteorites.erase(meteorite)

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

	var new_position = Vector3(new_x, new_y, last_z - Globals.platform_gap - (Globals.platform_base_length * 1.5))
	new_platform.global_transform.origin = new_position

	# Set the scale of the platform root node directly in code
	new_platform.scale = Vector3(width, Globals.platform_height, Globals.platform_base_length)  # Width, height (fixed), length (fixed)

	add_child(new_platform)
	
	platforms.append(new_platform)
	last_z = new_position.z
	last_y = new_position.y
	last_x = new_position.x
	last_width = width


func spawn_modifier(platform: Node3D, platform_width: float):
	if randi() % 4 == 0:  # 25% chance to spawn a modifier
		var modifier = modifier_scene.instantiate()

		var x_offset = randf_range(-platform_width / 2 + 0.5, platform_width / 2 - 0.5)
		var modifier_position = platform.global_transform.origin + Vector3(x_offset, Globals.platform_height + 0.5, 0)

		modifier.global_transform.origin = modifier_position

		# Connect collision detection for the modifier
		if modifier.has_signal("body_entered"):
			modifier.connect("body_entered", Callable(self, "_on_modifier_body_entered"))

		add_child(modifier)
		modifiers.append(modifier)
		print("Modifier added at position: ", modifier.global_transform.origin)
	
func _spawn_meteorite():
	var player_z = player.global_transform.origin.z
	print(player_z)
	var distant_platforms = platforms.filter(func(platform): 
		return platform.global_transform.origin.z < player_z - 20.0
	)
	print(distant_platforms)
	if distant_platforms.size() == 0:
		return
	var meteorite = meteorite_scene.instantiate()
	var random_platform = distant_platforms[randi() % distant_platforms.size()]
	meteorite.initialize(random_platform)
	print(random_platform)
	var target_position = random_platform.global_transform.origin
	var random_x_offset = randf_range(-5.0, 5.0)  # Desplazamiento aleatorio en el eje X
	var meteorite_start_position = target_position + Vector3(random_x_offset, 10, -10)  # 2 unidades por encima
	meteorite.global_transform.origin = meteorite_start_position  # Asignar la plataforma como objetivo
	meteorite.add_to_group("meteorites")
	add_child(meteorite)
	print(meteorite.get("target_platform"))
	meteorites.append(meteorite)
	

func _on_modifier_body_entered(body):
	for child in get_children():
		if child.name == "Modifier":  # Ensure it's a modifier
			if player.global_transform.origin.distance_to(child.global_transform.origin) < 1.0:
				print("Player collided with a modifier!")
				child.queue_free()

		
		# Add any effect you want here, e.g., reduce health or apply a status effect
