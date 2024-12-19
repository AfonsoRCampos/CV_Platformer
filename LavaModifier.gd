extends Area3D

@export var new_main_scene: PackedScene = preload("res://Lava.tscn") # Escena principal que se cargará al colisionar

func _ready():
	# Conectar la señal para detectar colisiones con el jugador
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Detectar si el jugador ha colisionado
	if body.name == "Player":  # Asegúrate de que el jugador tiene el nombre "Player"
		print("El jugador ha colisionado con el modificador.")
		load_new_scene()

func load_new_scene():
	# Cargar la nueva escena principal
	if new_main_scene:
		print("Cambiando a la nueva escena...")
		get_tree().change_scene_to_packed(new_main_scene)
	else:
		print("Error: No se ha asignado una nueva escena.")
