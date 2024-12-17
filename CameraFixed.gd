extends Camera3D

@export var player: Node3D  # Reference to the player node

func _process(delta):
	if player:
		look_at(player.global_transform.origin, Vector3.UP)  # Make the camera look at the player
