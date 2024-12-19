extends Node3D

@export var meteorite_group_name: String = "meteorites"  # Nombre del grupo para los meteoritos

func _ready():
	# Asegúrate de que la plataforma esté en el grupo "platforms" para facilitar la gestión
	add_to_group("platforms")
	var meteorites = get_tree().get_nodes_in_group(meteorite_group_name)
	for body in meteorites:
		if global_transform.origin.distance_to(body.global_transform.origin) < 0.5:
			print("Plataforma eliminada al detectar un meteorito cercano.")
			return  # Sal del bucle si ya eliminaste la plataforma
