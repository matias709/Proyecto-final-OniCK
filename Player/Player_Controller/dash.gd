extends State

func allowed_transitions() -> Array[StringName]:
	return [&"Idle", &"Walk"]

func enter(msg: Dictionary = {}) ->void:
	print ("Vector2.DOWN: ", actor.get_last_motion())
	
	if Input.is_action_just_pressed("ui_accept") and actor.can_dash:
		actor.can_dash = false
		actor.dashing = true
		var dir := actor.velocity.normalized()
		if dir == Vector2.ZERO:
			dir = Vector2.DOWN
		actor.velocity = dir * actor.dash_distance
		request(&"Walk")
		#actor.can_dash = true
		#actor.dashing = false
	#if not actor.dashing:
		#request(&"Walk")

func exit() -> void:
	actor.can_dash = true
	actor.dashing = false

#func update(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept") && actor.can_dash == true && actor.velocity == Vector2.ZERO:
		#actor.can_dash = false
		#actor.dashing = true
		#actor.velocity = actor.velocity.move_toward(Vector2.DOWN  * actor.dash_distance, actor.accel * delta)
	#elif Input.is_action_just_pressed("ui_accept") && actor.can_dash == true:
		#actor.can_dash = false
		#actor.dashing = true
		##actor.velocity += actor.get_last_motion().normalized() * actor.dash_distance
		#actor.velocity = actor.get_last_motion().normalized() * actor.dash_distance
	#
	#if actor.dashing == false:
		#request(&"Walk")
#
#func exit() -> void:
	#actor.can_dash = true
	#actor.dashing = false
