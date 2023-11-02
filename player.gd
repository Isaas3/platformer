extends CharacterBody2D

var is_firing_thong = false
var can_fire_thong = false
var is_dying = false
var is_jumping = false
var is_big = false
const SPEED = 300.0
const JUMP_VELOCITY = -350.0
var player_direction = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var thong_fire_timer = $ThongFireTimer

func _ready():
	add_to_group("Player")
	death_timer.connect("timeout", Callable(self, "_on_DeathTimer_timeout"))
	thong_fire_timer.connect("timeout", Callable(self, "_on_ThongFireTimer_timeout"))


func _physics_process(delta):
	if is_dying:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false


	if Global.current_state == Global.PlayerState.THONG and Input.is_action_just_pressed("fire"):
		fire_thong()
	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation(direction)
	move_and_slide()

func update_animation(direction):
	if is_dying or is_firing_thong:
		return
		
	
	match Global.current_state:
		Global.PlayerState.SMALL, Global.PlayerState.BIG:
			if is_jumping:
				animated_sprite_2d.play("jump")
			if direction != 0:
				animated_sprite_2d.flip_h = (direction < 0)
				animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("idle")
		Global.PlayerState.THONG:
			if is_jumping:
				animated_sprite_2d.play("thong_jump")
			if direction != 0:
				animated_sprite_2d.flip_h = (direction < 0)
				animated_sprite_2d.play("thong_run")
			else:
				animated_sprite_2d.play("thong_idle")

"""18:50"""

func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy") and body.is_alive:
		if is_big:
			become_small()
		else:
			die()
		
func die():
	if is_dying:
		return
		
	is_dying = true
	animated_sprite_2d.play("die")
	await move_player_up_and_down()
	Global.player_lives -= 1
	
	if Global.player_lives > 0:
		print("Reloading scene")
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://gameover.tscn")
	
func move_player_up_and_down():
	var start_position = position
	var up_position = start_position + Vector2(0, -100)
	var down_position = start_position + Vector2(0,600)
	
	while position.y > up_position.y:
		position.y -= 4
		await get_tree().create_timer(0.01).timeout
		
	while position.y < down_position.y:
		position.y += 4
		await get_tree().create_timer(0.01).timeout

func on_DeathTimer_timeout():
	get_tree().reload_current_scene()

func become_big():
	is_big = true
	self.scale = Vector2(1.5, 1.5)

func become_small():
	is_big = false
	self.scale = Vector2(1, 1)
	
