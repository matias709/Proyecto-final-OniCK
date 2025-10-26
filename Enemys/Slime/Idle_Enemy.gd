extends State
@onready var animatied_sprite : AnimatedSprite2D = $"../../../AnimatedSprite2D"

func allowed_transitions() -> Array[StringName]:
	return [&"Walk"]

func enter(msg := {}) -> void:
	# Frenar X suavemente al entrar en Idle
	actor.velocity.x = 0.0
	animatied_sprite.play("Idle")

func update(delta: float) -> void:
	#print ("ESTADO: Idle")
	#var axis = randi_range(1,50)
	#print(axis)
	#if axis == 25:
	request(&"Walk")
