extends State

@onready var animatied_sprite : AnimatedSprite2D = $"../../../AnimatedSprite2D"

func allowed_transitions() -> Array[StringName]:
	return [&"Idle"]

func update(delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		#animatied_sprite.play("Idle")
		actor.velocity = actor.velocity.move_toward(input_vector * actor.speed, actor.accel * delta)
	else:
		actor.velocity = actor.velocity.move_toward(Vector2.ZERO, actor.friction * delta)
