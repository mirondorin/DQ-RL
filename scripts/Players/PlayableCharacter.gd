extends "res://scripts/Entity.gd"


const flash_material = preload("res://materials/white.tres")


onready var current_weapon = $Weapon


var player_state
var start_position
var interactables = []
var weapon = 0
var cooldowns = {
	"can_light_attack" : true,
	"can_special_attack" : true,
	"can_utility" : true
}
var in_jump = false
var did_move = false
var landing = false
var in_dash = false
var start_time = -100
var jump_intensity


func _init():
	start_position = position
	self.SPEED = 100
	self.JUMPSPEED = 80
	stats["damage_modifier"] = 0
	stats["health"] = 100
	stats["max_health"] = 100


func init_game_data():
	init_gravity()


func _ready():
	set_physics_process(false)


func _unhandled_input(event):
	pass


func _process(delta):
	pass


func _physics_process(delta):
	MovementLoop(delta)
	DefinePlayerState()


func set_player_name(new_name):
	$DebugAction.text = new_name


func MovementLoop(delta):
	velocity.y += delta * self.GRAVITY
	solve_animation(velocity,delta)
	make_animation_calls()
	solve_impulse()
	velocity.x = x_direction * SPEED + impulse_dir.x * impulse_current_x
	var vel_y = velocity.y + impulse_dir.y * impulse_current_y
	var vel = Vector2(velocity.x, vel_y)
	move_and_slide(vel, Vector2(0, -1))
	if is_on_floor():
		velocity.y=0
		jump_intensity = 0
		in_jump=false
		impulse_current_x = 0
		impulse_current_y = 0
	if is_on_ceiling():
		velocity.y=max(0,velocity.y)
		impulse_current_y /= collision_resistance_factor
	if is_on_wall():
		impulse_current_x /= collision_resistance_factor
	solve_input(delta)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider.name == 'Mob':
			$DebugCollision.text = 'MOB'
		elif collision and collision.collider.name != 'Obstacles':
			$DebugCollision.text = collision.collider.name


func DefinePlayerState():
	player_state = {
		"T": OS.get_system_time_msecs(), 
		"P": position,
		"V": velocity  # TODO: try to send as less as possible, velocity shouldn't be necessary
	}
	Server.SendPlayerState(player_state)


func jump():
	var speed = -JUMPSPEED/20
	if is_on_floor():
		in_jump = true
		jump_intensity = 21
		start_time = OS.get_ticks_msec()
	var current_time = OS.get_ticks_msec()
	if current_time-start_time > 50:
		jump_intensity = 0
	else:
		start_time=current_time
	jump_intensity *= 0.80
	speed *= jump_intensity
	return speed


func dash(_delta):
	return 1
	in_dash = true
	$Hitbox.monitorable = false
	var dir = -1 if $AnimatedSprite.flip_h else 1
	GRAVITY = 0
	velocity.y = 0
	impulse(500, Vector2(dir, -0.001), 10, false)
	yield(get_tree().create_timer(0.2), "timeout")
	$Hitbox.monitorable = true
	in_dash = false
	self.impulse_current_x = impulse_current_x/3
	self.impulse_step = 5


func play_special_attack():
	$AnimationPlayer.play("special-attack")


func solve_animation(velocity,delta):
	if $AnimationPlayer.current_animation != 'special-attack':
		if x_direction !=0:
			if not key_has_value(animation_dict, "flip_h", (x_direction < 0)) and not Input.is_action_pressed("hold_direction"):
				animation_dict["flip_h"] = (x_direction < 0) 
				new_animation_dict["flip_h"] = (x_direction < 0)
				animation_change = true
	current_weapon.update_orientation($AnimatedSprite.flip_h)
	if in_jump or velocity.y > delta * GRAVITY + 0.1: #in jump/falling
		if not key_has_value(animation_dict, "animation", "jump"):
			animation_dict["animation"] = "jump"
			new_animation_dict["animation"] = "jump"
			animation_change = true
		landing=false
	elif is_on_floor():
		if $AnimatedSprite.animation == 'jump':
			animation_play = true
			animation_play_what = "land"
			if not key_has_value(animation_dict, "animation", "land"):
				animation_change = true
			landing = true
		else:
			if not key_has_value(animation_dict, "animation", "walk"):
				animation_dict["animation"] = "walk"
				new_animation_dict["animation"] = "walk"
				animation_change = true
	if velocity.length() != 0:
		if $AnimatedSprite.animation == 'jump' and $AnimatedSprite.frame == 2:
			animation_stop = true
		else:
			animation_play = true
			animation_play_what = ""


func on_gain_health():
	$HealthLabel.text = String(stats['health'])


func gain_health(value):
	stats['health'] += value
	on_gain_health()


func solve_input(delta):
	if Input.is_action_pressed("ui_left"):
		x_direction = -1
	elif Input.is_action_pressed("ui_right"):
		x_direction = 1
	else:
		x_direction = 0
	if Input.is_action_pressed("ui_up"):
		if not in_impulse:
			velocity.y += jump()
	if Input.is_action_pressed("ui_attack") and current_weapon.can_attack:
		current_weapon.attack()
		current_weapon.LightAttack_CD.start()
		current_weapon.can_attack = false
	elif Input.is_action_pressed("special_attack") and current_weapon.can_attack and weapon == 0:
		play_special_attack()
		current_weapon.SpecialAttack_CD.start()
		current_weapon.can_attack = false
	if Input.is_action_pressed("utility") and cooldowns['can_utility']:
		$Cooldown_Root/Utility_CD.start()
		cooldowns['can_utility'] = false
		dash(delta)
	if Input.is_action_just_pressed("interact"):
		use_interact()
	if Input.is_action_just_pressed("debug_test"): 
		var dir = (self.position - get_global_mouse_position()).normalized() * -1
		impulse(400, dir)
	if Input.is_action_just_pressed("debug_switch_weapon"):
		switch_weapon()
	if Input.is_action_just_pressed("change_level"):
		scene_handler.change_level()


func do_switch_weapon():
	weapon = (1 + weapon) % 3
	current_weapon.queue_free()
	var wep
	if weapon == 1:
		wep = load("res://scenes/Weapons/WeaponProjectile.tscn")
	elif weapon == 0:
		wep = load("res://scenes/Weapons/Weapon.tscn")
	elif weapon == 2:
		wep = load("res://scenes/Weapons/WeaponBomb.tscn")
	var inst = wep.instance()
	current_weapon = inst
	add_child(inst)


func switch_weapon():
	do_switch_weapon()


func out_of_bounds():
	position = start_position


func on_take_damage(direction, impulse_force):
	$AnimatedSprite.set_material(flash_material)
	yield(get_tree().create_timer(0.15), "timeout")
	$AnimatedSprite.set_material(null)
	if not key_has_value(animation_dict, "animation", "hit"):
		animation_dict["animation"] = "hit"
		new_animation_dict["animation"] = "hit"
		animation_change = true
	$HealthLabel.text = String(stats['health'])
	animation_play = true
	animation_play_what = ""
	if stats['health'] <= 0:
		$HealthLabel.text = 'dead!'
		$HealthLabel.add_color_override("font_color", Color(255, 0, 0))


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == 'land':
		landing = false
		animation_play = true
		animation_play_what = "walk"
	animation_stop = true


func _on_Utility_CD_timeout():
	cooldowns['can_utility'] = true


func grab_item():
	print("Called grab item")


func use_interact():
	for i in interactables:
		i.get_parent().interact()
		return


func do_modify_stats(status, value):
	stats[status] 	+= value
	$HealthLabel.text = String(stats['health'])


func modify_stats(status, value):
	do_modify_stats(status, value)


func _on_Hitbox_area_entered(area):
	if area.is_in_group("interactable"):
		interactables.append(area)


func _on_Hitbox_area_exited(area):
	if area.is_in_group("interactable"):
		interactables.erase(area)

