class_name State
extends Node

var machine: Node
var actor: CharacterBody2D
var anim

func id() -> StringName:
	return name

func allowed_transitions() -> Array[StringName]:
	return []

func enter(msg: Dictionary = {}) ->void:
	pass

func exit() -> void:
	pass

func handle_input(event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	pass

func request(to: StringName, ctx: Dictionary = {}) -> bool:
	return machine.request_transition(to, ctx)

func can_request(to: StringName, ctx: Dictionary = {}) -> bool:
	return machine.can_transition_to(to, ctx)
