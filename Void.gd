extends Area3D

@export var player: CharacterBody3D
@export var new_main_scene: PackedScene = preload("res://Main.tscn") # Escena principal que se cargará al colisionar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_transform.origin.y = Globals.min_y - 1
	player = get_node("../Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_transform.origin.z = player.global_transform.origin.z
	

func reset() -> void:
	queue_free()
