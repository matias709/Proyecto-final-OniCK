extends State

var target_position_global:Vector2
var current_position: Vector2
var direction

func allowed_transitions() -> Array[StringName]:
	return [&"Idle"]

func enter(msg := {}) -> void:
	var current_position = actor.global_position
	var offset = Vector2(randi_range(-100, 100), randi_range(-100, 100))
	
	target_position_global = current_position + offset
	direction = actor.global_position.direction_to(target_position_global)
	print("Moviéndome desde ", current_position, ", hacia ", target_position_global, ", la direccion es: ",direction)

func update(delta: float) -> void:
	print("la distancia es: ", actor.global_position.distance_to(target_position_global))
	print("posicion actual: ", actor.global_position)
	
	if actor.global_position.distance_to(target_position_global) < 10:
		print("llegue")
		request(&"Idle")
	actor.velocity = direction * actor.accel * delta
