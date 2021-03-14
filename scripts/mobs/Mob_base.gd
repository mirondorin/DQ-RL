extends "res://scripts/Entity.gd"

var spawner = null

export var follow = true

var player
onready var attack_timer = $'AttackCooldown'
onready var jump_timer = $'JumpCooldown'

var is_dead = false

puppet var puppet_velocity = Vector2()
puppet var puppet_pos = Vector2()

var in_jump = false
var can_jump = false
var can_attack = true
var jump_intensity = 0
var start_time = -100

var attack_damage = 10
var attack_cooldown = 1.5	
var jump_cooldown = 4

var in_area = []

func _init():
	stats["health"] = 20

func _ready():
	if is_network_master():
		attack_timer.wait_time = attack_cooldown	
		jump_timer.wait_time = jump_cooldown
		jump_timer.start()

func jump():
	var speed = -JUMPSPEED/20
	if is_on_floor():
		in_jump = true
		jump_intensity = 60
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
	else:
		follow = false
		x_direction = 0
		return 1
	if position.x < player.position.x:
		x_direction = 1
	else:
		x_direction = -1
	
	if not follow or abs(position.x - player.position.x) < 15:
		x_direction = 0

func attack_player(_player):
	pass

func solve_animation(velocity):
	if  is_network_master():
		if velocity.x != 0:
			rpc_unreliable("change_animation", "flip_h", velocity.x < 0)
			rpc_unreliable("change_animation", "animation", 'walk')
		if velocity.x == 0:
			rpc_unreliable("change_animation", "animation", 'idle')
	pass

func out_of_bounds():
	# we can add invisible objects, boundaries, and 
	# _on_Area2D_body_entered => direction *= -1
	# to ensure that the enemy patrols only one zone
	rpc("kill_mob")
	
sync func kill_mob():
	is_dead = true
	queue_free()
	if spawner != null:
		spawner.decrease_spawned()
	pass
	
func _physics_process(delta):
	if is_network_master():
		follow_player()
		velocity.y += delta * GRAVITY
		
		if can_jump and follow and len(in_area) > 0 and position.y >= player.position.y - 5:
			velocity.y += jump()
			can_jump = false
		
		solve_animation(velocity)
		solve_impulse()
		
		velocity.x = x_direction * SPEED + impulse_dir.x * impulse_current_x
		var vel_y = velocity.y + impulse_dir.y * impulse_current_y
		move_and_slide(Vector2(velocity.x , vel_y), Vector2(0, -1))
		
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
		
		if in_impulse:
			x_direction = 0

		for i in get_slide_count():
			if get_slide_count() > i:
				var collision = get_slide_collision(i)
				if collision and collision.collider.is_in_group("players") and follow:
					attack_player(collision.collider)
		
		rpc_unreliable("set_entity_position", position, velocity)
	
#	if Input.is_action_just_pressed("debug_test"): 
#		var dir = (self.position - get_global_mouse_position()).normalized() * -1
#		impulse(400, dir)
	
func on_take_damage():
	if not is_dead:
		if stats["health"] > 0:
			$HealthLabel.text = String(stats["health"])
		else:
#			if is_network_master():
#				rpc("kill_mob") # on_take_damage is called from all peers
			kill_mob()
	follow = false
	impulse(50, Vector2(get_x_orientation() * -1, -1))
	attack_timer.start()
	pass

func _on_DetectArea_body_entered(body):
	if not body in in_area:
		if body.is_in_group("players"):
			in_area.append(body)
			follow = true
	pass

func _on_DetectArea_body_exited(body):
	if body in in_area:
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

