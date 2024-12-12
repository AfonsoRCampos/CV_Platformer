extends Node3D

@export var player: Node3D  # Reference to the player node
@export var void_threshold: float = Globals.min_y - 1.0  # Y value for the void threshold

func _ready() -> void:
	# Ensure we have a valid player reference
	if player == null:
		player = $Player/CharacterCollision

func _process(delta: float) -> void:
	if player.global_transform.origin.y < void_threshold:
		game_over()

func game_over():
	print("Game Over!")
	Globals.reset()  # Reset global game variables
	$Player.reset()  # Call a reset function in the player script
	$PlatformManager.reset()  # Reset platforms
