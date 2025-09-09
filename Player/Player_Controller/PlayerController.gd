class_name PlayerControler extends CharacterBody2D

# variables de movimiento
@export var speed: float = 300.0
@export var friction: float = 1000.0
@export var accel: float = 1500.0
@export var decel: float = 2200.0

#variables de sprite
@onready var animation

func _ready() -> void:
	animation = get_node("AnimatedSprite2D")

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		animation.play("Idle")
		velocity = velocity.move_toward(input_vector * speed, accel * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
