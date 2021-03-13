extends KinematicBody2D

var spawner = null

export var follow = true
export var SPEED = 90
export var JUMPSPEED = 320
onready var GRAVITY = get_tree().get_root().get_node('MainScene/GlobalSettings').GRAVITY
export var air_resistance_factor = 11
export var collision_resistance_factor = 3


var player
onready var attack_timer = $'AttackCooldown'
onready var jump_timer = $'JumpCooldown'

export var health = 20
puppet var puppet_health

var is_dead = false

var velocity = Vector2()

puppet var puppet_velocity = Vector2()
puppet var puppet_pos = Vector2()

var x_direction = 0
var in_jump = false
var can_jump = false
var can_attack = true
var jump_intensity = 0
var start_time = -100

var attack_damage = 10
var attack_cooldown = 1.5	
var jump_cooldown = 4

var in_area = []

func _ready():
	attack_timer.wait_time = attack_cooldown	
	jump_timer.wait_time = jump_cooldown
	jump_timer.start()

	
func jump(time):
	var speed = -JUMPSPEED/20
	if is_on_floor():
		in_jump = true
		jump_intensity = 20
		start_time = OS.get_ticks_msec()
	var current_time = OS.get_ticks_msec()
	if current_time-start_time>50:
		jump_intensity = 0
	else:
		start_time=current_time
	jump_intensity*=0.80
	speed*=jump_intensity
	return speed
	pass

func follow_player():
	if len(in_area) > 0:
		player = in_area[0]
		follow = true
	else:
		follow = false
		x_direction = 0
		return 1
	if position.x < player.position.x:
		x_direction = 1
	else:
		x_direction = -1
	
	if not follow:
		x_direction = 0

func attack_player(player):
	pass

func solve_animation(velocity, delta):
	if velocity.x != 0:
		$AnimatedSprite.flip_h = x_direction < 0
		$AnimatedSprite.animation = 'walk'
	if velocity.x == 0:
		$AnimatedSprite.animation = 'idle'
	pass

func out_of_bounds():
#	? TODO: check how to networking

	# we can add invisible objects, boundaries, and 
	# _on_Area2D_body_entered => direction *= -1
	# to ensure that the enemy patrols only one zone
	is_dead = true
	queue_free()
	if spawner != null:
		spawner.decrease_spawned()

var impulse_force = 0
var impulse_current_x = 0
var impulse_current_y = 0
var impulse_dir = Vector2(0, 0)
var in_impulse = false
var impulse_step = 5

func impulse(force, direction, step = 5, additive = true):
	if additive: 
		impulse_current_x += force
		impulse_current_y += force
	else:
		impulse_current_x = force
		impulse_current_y = force
	impulse_dir = direction
	impulse_step = step
	in_impulse = true

func solve_impulse():
	if impulse_current_x > 0:
		impulse_current_x -= impulse_step + abs(x_direction) * SPEED/air_resistance_factor
		
	if impulse_current_y > 0:
		impulse_current_y -= impulse_step
		
	if impulse_current_x <= 0:
		impulse_current_x = 0
		impulse_dir.x = 0
		
	if impulse_current_y <= 0:
		impulse_current_y = 0
		impulse_dir.y = 0
		
	if impulse_current_x <= 0 and impulse_current_y <= 0:
		impulse_step = 5
		in_impulse = false

func _physics_process(delta):
	follow_player()
	velocity.y += delta * GRAVITY
	solve_impulse()
	
	if is_network_master():
		if is_on_floor():
			velocity.y = 0
			jump_intensity = 0
			in_jump=false
			impulse_current_x = 0
			impulse_current_y = 0
			
		if is_on_ceiling():
			velocity.y=max(0,velocity.y)
			impulse_current_y /= collision_resistance_factor
	
		if is_on_wall():
			impulse_current_x /= collision_resistance_factor
		
		if can_jump and follow and len(in_area) > 0 and position.y >= player.position.y - 5:
			velocity.y += jump(delta)
			can_jump = false
		rset("puppet_pos", position)
		rset("puppet_velocity", velocity)
	else:
		position = puppet_pos
		velocity = puppet_velocity
	
	if in_impulse:
		x_direction = 0
		
	if Input.is_action_just_pressed("debug_test"): 
		var dir = (self.position - get_global_mouse_position()).normalized() * -1
		impulse(400, dir)
	
	solve_animation(velocity, delta)

	velocity.x = x_direction * SPEED + impulse_dir.x * impulse_current_x
	var vel_y = velocity.y + impulse_dir.y * impulse_current_y
	move_and_slide(Vector2(velocity.x , vel_y), Vector2(0, -1))
	
	var previous = get_slide_count()
	for i in get_slide_count():
		if get_slide_count() > i:
			var collision = get_slide_collision(i)
			if collision and collision.collider.is_in_group("players") and follow:
				attack_player(collision.collider)

func on_take_damage():
	if not is_dead:
		if health > 0:
			$HealthLabel.text = String(health)
		else:
			is_dead = true
			queue_free()
			if spawner != null:
				spawner.decrease_spawned()
	follow = false
	attack_timer.start()
	pass

func take_damage(value):
	health -= value
	on_take_damage()
	pass

func _on_DetectArea_body_entered(body):
	if not body in in_area:
		if body.is_in_group("players"):
			in_area.append(body)
	pass

func _on_DetectArea_body_exited(body):
	if not body in in_area:
		if body.is_in_group("players"):
			in_area.erase(body)
	pass

func _on_AttackCooldown_timeout():
	can_attack = true
	follow = true
	pass
	
func _on_JumpCooldown_timeout():
	can_jump = true
	pass

