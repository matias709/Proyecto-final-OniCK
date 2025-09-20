extends State

var position_random:Vector2i

func allowed_transitions() -> Array[StringName]:
	return [&"Idle"]

func enter(msg := {}) -> void:
	position_random = anim.position + Vector2i(randi_range(-5,5), randi_range(-5,5))
