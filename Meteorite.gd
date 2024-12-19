extends Area3D

@export var speed: float = 10.0  # Velocidad del meteorito
var target_platform: Node3D  # Referencia a la plataforma objetivo
var direction: Vector3 = Vector3.ZERO  # Dirección hacia la plataforma

func _ready():
	# Verifica si el objetivo está asignado
	if target_platform:
		# Calcula la dirección hacia el objetivo
		direction = (target_platform.global_transform.origin - global_transform.origin).normalized()
	else:
		print("Error: No se asignó una plataforma objetivo al meteorito.")  # Eliminar el meteorito si no tiene objetivo

	# Conectar la señal para detectar colisiones
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	if not target_platform:
		return  # No hacer nada si no hay plataforma objetivo

	# Mueve el meteorito hacia la plataforma objetivo
	var movement = direction * speed * delta
	global_transform.origin += movement

	# Comprobar si el meteorito está lo suficientemente cerca de la plataforma
	if global_transform.origin.distance_to(target_platform.global_transform.origin) < 0.5:
		print("Meteorito impactó la plataforma en:", target_platform.global_transform.origin)
		target_platform.queue_free()  # Eliminar la plataforma objetivo
		explode()  # Realizar el efecto de explosión
		queue_free()  # Eliminar el meteorito

func _on_body_entered(body):
	# Detectar colisión con plataformas
	if body.is_in_group("platforms"):  # Asegúrate de que las plataformas están en el grupo "platforms"
		print("Meteorito colisionó con una plataforma.")
		body.queue_free()  # Eliminar la plataforma impactada
		explode()  # Realizar el efecto de explosión
		queue_free()  # Eliminar el meteorito

func explode():
	# Añadir efectos visuales o de sonido aquí
	print("¡Impacto del meteorito!")
	
func initialize(target: Node3D):
	target_platform = target
	if target_platform:
		direction = (target_platform.global_transform.origin - global_transform.origin).normalized()
		print("Meteorito inicializado con plataforma objetivo:", target_platform.global_transform.origin)
	else:
		print("Error: No se asignó una plataforma objetivo al meteorito.")
		queue_free()  # Eliminar el meteorito si no tiene objetivo
