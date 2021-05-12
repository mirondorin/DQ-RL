extends "res://scripts/Entity.gd"
const flash_material = preload("res://materials/white.tres")

onready var current_weapon = $Weapon

var screen_size # Size of the game window

var player_pos = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_pos = Vector2()

var start_time = -100
var jump_intensity
var in_jump = false
var did_move = false
var landing = false
var in_dash = false
var cooldowns = {
	"can_utility" : true
		}
var weapon = 0
var weapon_animations = {0 : "special-attack-sword",
						1 : "special-attack-staff"
}

var camera
var interactables = []

#export var health = 100
#puppet var puppet_health = health
# !! maybe it's not needed, as it doesn't change periodically

var start_position

func set_player_name(new_name):
#	get_node("label").set_text(new_name)
	$DebugAction.text = new_name
	pass

func _init():
	self.SPEED = 100
	self.JUMPSPEED = 80
	stats["damage_modifier"] = 0
	stats["health"] = 100
	stats["max_health"] = 100
	stats["regen_delay"] = 1
	stats["regen_value"] = 2
	


func _ready():
	if is_network_master():
		camera = Camera2D.new()
		self.add_child(camera)
		camera.make_current()
		camera.set_zoom(Vector2( 0.5, 0.5 ))

func jump():
#	This method does not have to be synced
#	since it only calculates jump speed
#	client can cheat, but does he really?
	var speed = -JUMPSPEED/20
	if is_on_floor():
		in_jump = true
		jump_intensity = 21
		start_time = OS.get_ticks_msec()
	var current_time = OS.get_ticks_msec()
	if current_time-start_time>50:
		jump_intensity = 0
	else:
		start_time=current_time
	jump_intensity *= 0.80
	speed *= jump_intensity
	return speed
	pass
	
func dash(_delta):
	on_dash_sfx()
	in_dash = true
	$Hitbox.monitorable = false
	var dir = -1 if $AnimatedSprite.flip_h else 1
	self.GRAVITY = 0
	velocity.y = 0
	impulse(500, Vector2(dir, -0.001), 10, false)
	yield(get_tree().create_timer(0.2), "timeout")
	self.GRAVITY = GlobalSettings.GRAVITY
	$Hitbox.monitorable = true
	in_dash = false
	self.impulse_current_x = impulse_current_x/3
	self.impulse_step = 5

sync func play_special_attack():
	$AnimationPlayer.play(weapon_animations[weapon])
	current_weapon.get_node("AnimationPlayer").play("special-attack")
	if weapon == 0:
		animation_dict["flip_h"] = false


func solve_animation(velocity,delta):
	if not is_network_master():
		return 1
	if current_weapon.get_node("AnimationPlayer").current_animation != 'special-attack':
		if x_direction !=0:
			if not key_has_value(animation_dict, "flip_h", (x_direction < 0))\
				 and not Input.is_action_pressed("hold_direction"):
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

sync func gain_health(value):
	stats['health'] += value
	on_gain_health()

func solve_input(delta):
#	theoretically should not require sync
#	but we have to find a way to sync weapon attacks and animations
	if Input.is_action_pressed("left"):
		x_direction = -1
	elif Input.is_action_pressed("right"):
		x_direction = 1
	else:
		x_direction = 0
		
	if Input.is_action_pressed("up"):
		if not in_impulse:
			velocity.y += jump()
		
	if Input.is_action_pressed("attack") and current_weapon.can_attack:
		current_weapon.attack()
		current_weapon.LightAttack_CD.start()
		current_weapon.can_attack = false
	elif Input.is_action_pressed("special_attack") and current_weapon.can_special_attack:
		rpc_unreliable("play_special_attack")
		current_weapon.SpecialAttack_CD.start()
		current_weapon.can_special_attack = false
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
		gamestate.change_level()


func _physics_process(delta):
	if is_network_master():
		velocity.y += delta * GRAVITY
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
		rpc_unreliable("set_entity_position", position)

func regen_health():
	if stats["health"] < stats["max_health"]: 
		var bodies = $RegenArea.get_overlapping_bodies()
		for entity in bodies:
			if entity.is_in_group("players") and entity != self:			
				set_stats("health", clamp(stats["health"] + stats["regen_value"], 0, stats["max_health"]))
				break

sync func do_switch_weapon():
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
	rpc("do_switch_weapon")


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
	pass


func _on_Utility_CD_timeout():
	cooldowns['can_utility'] = true
	pass


func grab_item():
	print("Called grab item")


func use_interact():
	for i in interactables:
		i.get_parent().interact(self)
		return


func _on_Hitbox_area_entered(area):
	if area.is_in_group("interactable"):
		interactables.append(area)


func _on_Hitbox_area_exited(area):
	if area.is_in_group("interactable"):
		interactables.erase(area)
		
func on_dash_sfx():
	$DashSfx.play()


func _on_RegenTimer_timeout():
	regen_health()
