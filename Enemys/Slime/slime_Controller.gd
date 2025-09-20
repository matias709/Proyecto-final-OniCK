class_name SlimeController extends CharacterBody2D

#variables de movimiento
@export var speed: float = 150.0
@export var friction: float = 1000.0
@export var accel: float = 1500.0
@export var decel: float = 2200.0
@export var dash_distance: float = 500.0
@export var can_dash: bool = true
@export var dashing: bool = false

#variables de sprite
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sm: StateMachine = $StateMachine

func _physics_process(delta: float) -> void:
	# El StateMachine/estado actual ya habrá ajustado velocity.x
	# y, si corresponde, habrá aplicado el impulso de salto en velocity.y.
	move_and_slide()
