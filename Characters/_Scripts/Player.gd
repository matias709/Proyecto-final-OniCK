extends CharacterBody2D

@export var speed: float = 300.0
@export var friction: float = 1000.0
@export var acceleration: float = 1500.0

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
