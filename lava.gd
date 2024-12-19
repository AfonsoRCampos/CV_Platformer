extends Node3D

@export var player: Node3D  # Reference to the player node
@export var void_threshold: float = Globals.min_y -1.0  # Y value for the void threshold
@export var new_main_scene: PackedScene = ResourceLoader.load("res://Main.tscn")  # Asegúrate de tener un Meteorite.tscn
var game_over_triggered: bool = false
func _ready() -> void:
	# Ensure we have a valid player reference
	if player == null:
		player = $Player/CharacterCollision
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if not game_over_triggered and player.global_transform.origin.y < void_threshold:
		game_over_triggered = true  # Marca el "Game Over" como activado
		game_over()
		
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Default action mapped to the Escape key
		get_tree().quit()

func game_over():
	if new_main_scene:
		Globals.game_started= false
		get_tree().call_deferred("change_scene_to_packed", new_main_scene) # Establece la nueva escena como actual
	else:
		print("Error: No se pudo cargar la escena principal.")
	
func load_new_scene():
	# Cargar la nueva escena principal
	if new_main_scene:
		print("Cambiando a la nueva escena...")
		print(new_main_scene)
		get_tree().change_scene_to_packed(preload("res://Main.tscn"))
	else:
		print("Error: No se ha asignado una nueva escena.")
