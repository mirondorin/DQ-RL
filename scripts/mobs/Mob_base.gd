extends "res://scripts/Entity.gd"

const flash_material = preload("res://materials/white.tres")
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
#onready var	GlobalSettings = get_node("/root/MainScene/GlobalSettings")

func _init():
	stats["health"] = 25
	
func _ready():
	return 1
	if is_network_master():
		attack_timer.wait_time = attack_cooldown	
		jump_timer.wait_time = jump_cooldown
		jump_timer.start()
#		var lvl_nr = GlobalSettings.level_nr
		var lvl_nr = 0
		if self.is_in_group("boss"):
			set_initial_health(stats["health"] * (lvl_nr + 2) / 2)
		else:
			set_initial_health(stats["health"] * (lvl_nr + 2) / 2)
		

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
	
	if not follow or abs(position.x - player.position.x) < 10:
		x_direction = 0

func attack_player(_player):
	pass

func solve_animation(velocity):
	if x_direction != 0:
		if not key_has_value(animation_dict, "flip_h", (x_direction < 0)):
			animation_dict["flip_h"] = (x_direction < 0)
			new_animation_dict["flip_h"] = (x_direction < 0)
			animation_change = true
		if not key_has_value(animation_dict, "animation", "walk"):
			animation_dict["animation"] = 'walk'
			new_animation_dict["animation"] = 'walk'
			animation_change = true
	if velocity.x == 0:
		if not key_has_value(animation_dict, "animation", "idle"):
			animation_dict["animation"] = 'idle'
			new_animation_dict["animation"] = 'idle'
			animation_change = true
			

func out_of_bounds():
	rpc("kill_mob")
	
sync func kill_mob():
	is_dead = true
	queue_free()
	if spawner != null:
		spawner.decrease_spawned()
	pass
	
func _physics_process(delta):
	return 1
	if is_network_master():
		follow_player()
#		velocity.y += delta * GRAVITY
		
		if can_jump and follow and len(in_area) > 0 and position.y >= player.position.y - 5:
			velocity.y += jump()
			can_jump = false
		
		solve_animation(velocity)
		make_animation_calls()
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
	
func on_take_damage(direction, impulse_force):
#	TODO: check how to optimize this and normalize it since we use it on both player and mob
	if not is_dead:
		if stats["health"] > 0:
			$HealthLabel.text = String(stats["health"])
			if stats['stagger_health'] <= 0:
				impulse(impulse_force, Vector2(direction.x, -1 if direction.y == 0 else direction.y))
				stats['stagger_health'] = stats['stagger_default']
				follow = false
			$AnimatedSprite.set_material(flash_material)
			SPEED = SPEED / 2
			yield(get_tree().create_timer(0.15), "timeout")
			SPEED = stats['default_speed']
			$AnimatedSprite.set_material(null)
		else:
			kill_mob()
	attack_timer.start()

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

