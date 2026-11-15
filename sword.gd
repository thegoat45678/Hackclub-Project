extends CharacterBody2D

enum State { IDLE, SWING }
var current_state: State = State.IDLE

@export var knockback_force: float = 800.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Area2D

func _ready() -> void:
	anim.stop()
	hitbox.monitoring = true
	set_state(State.IDLE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if current_state == State.IDLE:
			set_state(State.SWING)

func set_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.IDLE:
			anim.frame = 0
		State.SWING:
			anim.frame = 1
			hit_enemies_in_range()
			await get_tree().create_timer(0.2).timeout
			set_state(State.IDLE)

func hit_enemies_in_range() -> void:
	await get_tree().physics_frame
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			var push_dir = sign(body.global_position.x - global_position.x)
			if push_dir == 0:
				push_dir = 1
			if body.has_method("apply_knockback"):
				body.apply_knockback(push_dir * knockback_force)
