class_name StateMachine
extends Node

@export var policy: NodePath
@export var animation_manager: NodePath

@onready var actor := get_parent() as CharacterBody2D
@onready var _state_root := $States
var _policy_ref: Node = null
var _anim_ref: Node = null

var currentState:State = null

func _ready() -> void:
	if policy != NodePath():
		_policy_ref = get_node_or_null(policy)
	if animation_manager != NodePath():
		_anim_ref = get_node_or_null(animation_manager)
	
	for child in State:
		if child is State:
			child.machine = self
			child.actor = actor
			child.anim = _anim_ref
			child.set_physics_proccess(false)

	var initial: State = _get_state_node(&"Idle")
	if initial == null:
		push_warning("stateMachine: No se encontro el estado unicial")
		initial = _first_state_or_null()
	if initial:
		set_state(initial,{})

func _unhandled_input(event: InputEvent) -> void:
	if currentState:
		currentState.handel_input(event)

func _physics_process(delta: float) -> void:
	if currentState:
		currentState.update(delta)

func can_tramsition_to(to_id: StringName, ctx:Dictionary = {}) -> bool:
	if currentState == null:
		return true
	
	if to_id not in currentState.allowed_transitions():
		return false
	
	if _policy_ref and _policy_ref.has_method("can_transition"):
		return _policy_ref.can_transition(currentState.id(), to_id, ctx)
	return true

func request_transition(to_id: StringName, ctx:Dictionary = {}) -> bool:
	if currentState and to_id == currentState.id():
		return false
	
	if !can_tramsition_to(to_id, ctx):
		pass
	return false

func _get_state_node(name: StringName) -> State:
	return null

func set_state(state: State, ctx:Dictionary={}) -> void:
	pass 

func _first_state_or_null() -> State:
	return null
