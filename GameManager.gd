extends Node3D

@export var player: Node3D  # Reference to the player node
@export var void_threshold: float = Globals.min_y - 1.0  # Y value for the void threshold

func _ready() -> void:
	# Ensure we have a valid player reference
	if player == null:
		player = $Player/CharacterCollision
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if player.global_transform.origin.y < void_threshold:
		game_over()
		
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Default action mapped to the Escape key
		get_tree().quit()


func game_over():
	print("Game Over!")
	Globals.reset()  # Reset global game variables
	$Player.reset()  # Call a reset function in the player script
	$PlatformManager.reset()  # Reset platforms
