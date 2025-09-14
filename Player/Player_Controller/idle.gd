extends State


@onready var animatied_sprite : AnimatedSprite2D = $"../../../AnimatedSprite2D"

func allowed_transitions() -> Array[StringName]:
	return [&"Walk", &"Dash"]

func enter(msg := {}) -> void:
	# Frenar X suavemente al entrar en Idle
	actor.velocity.x = 0.0
	animatied_sprite.play("Idle")

func update(delta: float) -> void:
	print ("ESTADO: Idle")
	var axis := Input.get_action_strength("move_right") - Input.get_action_strength("move_left") - Input.get_action_strength("move_up") - Input.get_action_strength("move_down")

	if axis != 0.0:
		request(&"Walk")
	
	if Input.is_action_just_pressed("ui_accept"):
		request(&"Dash")
