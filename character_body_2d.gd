extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_dead: bool = false
var starting_position: Vector2

@onready var sword = $Sword # Make sure your Sword child node is named "Sword"

func _ready() -> void:
	starting_position = global_position

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		# Flip the sword and its hitbox left/right when turning
		if sword:
			sword.scale.x = 1 if direction > 0 else -1
			sword.position.x = abs(sword.position.x) * (1 if direction > 0 else -1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Die if bumping into a monster
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.is_in_group("enemy"):
			die()
			return

func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	visible = false
	set_physics_process(false)
	
	var saved_layer = collision_layer
	var saved_mask = collision_mask
	collision_layer = 0
	collision_mask = 0
	
	await get_tree().create_timer(1.0).timeout
	
	velocity = Vector2.ZERO
	global_position = starting_position
	visible = true
	collision_layer = saved_layer
	collision_mask = saved_mask
	set_physics_process(true)
	is_dead = false
