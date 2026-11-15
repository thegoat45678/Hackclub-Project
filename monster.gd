extends CharacterBody2D

@export var move_distance: float = 200.0
@export var move_speed: float = 100.0

var start_x: float
var direction: int = 1
var is_knocked_back: bool = false

func _ready() -> void:
	add_to_group("enemy")
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_knocked_back:
		velocity.x = move_toward(velocity.x, 0, 1200 * delta)
	else:
		velocity.x = direction * move_speed
		if global_position.x >= start_x + move_distance:
			direction = -1
		elif global_position.x <= start_x:
			direction = 1

	move_and_slide()

	if not is_knocked_back:
		for i in get_slide_collision_count():
			var collider = get_slide_collision(i).get_collider()
			if collider and collider.has_method("die"):
				collider.die()

func apply_knockback(force: float) -> void:
	if is_knocked_back:
		return
		
	is_knocked_back = true
	velocity.x = 1200
	velocity.y = -600
	
	# Bounce away for 0.4 seconds, then disappear
	
