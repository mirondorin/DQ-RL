extends KinematicBody2D

onready var current_weapon = $Weapon

export var SPEED = 100
export var JUMPSPEED = 80
onready var GRAVITY = get_node('../../GlobalSettings').GRAVITY
var screen_size # Size of the game window

var velocity = Vector2()
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
	"can_light_attack" : true,
	"can_special_attack" : true,
	"can_utility" : true
		}

var can_attack = true

export var health = 100
puppet var puppet_health = health
# !! maybe it's not needed, as it doesn't change periodically

var start_position

func set_player_name(new_name):
#	get_node("label").set_text(new_name)
	$DebugAction.text = new_name
	pass

func _ready():
	screen_size = get_viewport_rect().size
	start_position = position
	player_pos = position
	pass

func jump(time):
#	This method does not have to be synced
#	since it only calculates jump speed
#	client can cheat, but does he really?
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
	jump_intensity *= 0.80
	speed *= jump_intensity
	return speed
	pass
	
sync func dash(delta):
#	dash ought to be sync-ed, since it modifies player velocity

#	!! however it could be better to refactor and do all king of motion movement 
#	in main loop, this method should only return

#	TODO: the above mentioned refactoring
	if not in_dash:
		return
	var direction = 0
	if velocity.x != 0:
		direction = 1 if velocity.x > 0 else -1
	else:
		direction = 1 if $AnimatedSprite.flip_h == false else -1
#	maybe here we should check if is network master, to sync velocity
	if is_network_master():
		velocity.x += 400 * direction
		rset("puppet_velocity", velocity)
	else:
		velocity = puppet_velocity
		puppet_pos = position  # ?? it may avoid jitter, but also it may not
	pass

func solve_animation(velocity, delta):
#	I don't really know if animation should be sync or not
#	future testing is required
#	an example was: lot of ifs to set new animation
#	and play it if different from current one
#	no sync was 

#	doesn't seem to work for us

#	FIXME: when you find out how
	if velocity.x != 0:
		if $AnimationPlayer.current_animation != 'special-attack':
			$AnimatedSprite.flip_h = velocity.x < 0
	current_weapon.update_orientation($AnimatedSprite.flip_h)
			
	if in_jump or velocity.y>delta*GRAVITY+0.1: #in jump/falling
		$AnimatedSprite.animation='jump'
		landing=false
			
	elif is_on_floor():
		if $AnimatedSprite.animation=='jump':
			$AnimatedSprite.play('land')
			landing = true
		else:
			$AnimatedSprite.animation='walk'
	if velocity.length()!=0:
		if $AnimatedSprite.animation=='jump' and $AnimatedSprite.frame==2:
			$AnimatedSprite.stop()
		else:
			$AnimatedSprite.play()
	pass

func on_lose_hp():
#	solving animation (as I know it) should not require sync
#	however $Health.text doesn't seem to sync on players. 

#	maybe we could do ??? (a refactoring I suppose, to get all modifications
#	to be made to [x for x in velocity, position, animations, health] returned
#	to main loop and do them all there)
#	!! this ^ is supposed to be done only if it really works
#	I say it should, but I have to ask the compiler

#	probably we also need a puppet animation var
#	and maybe a puppet health var
	$AnimatedSprite.animation='hit'
	$Health.text = String(health)
	$AnimatedSprite.play()
	if health <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))
	pass

func on_gain_health():
#	copy paste comments above here
	$Health.text = String(health)
	pass

func take_damage(value):
#	this has to be sync-ed, or should return modifications made

#	version 1.0.3: this doesn't have to be sync-ed anymore, checking network
#	master is enough
#	or is supposed to be enough, testing will prove it (wrong)

#	on further thought, we could have used something like:

#	puppet func take_damage():
#		takes_damage()
#	master func damage_control()
#		rpc("take_damage")
#		take_damage()
	if is_network_master():
		health -= value
		rset("puppet_health", health)
	else:
		health = puppet_health
	on_lose_hp()
	pass

sync func gain_health(value):
#	copy paste comments above here
	if is_network_master():
		health += value
		rset("puppet_health", health)
	else:
		health = puppet_health
	on_gain_health()
	pass

func solve_input(delta):
#	theoretically should not require sync
#	but we have to find a way to sync weapon attacks and animations
	var v_x = 0
	var v_y = velocity.y
	if Input.is_action_pressed("ui_left"):
		v_x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		v_x = SPEED
	else:
		v_x = 0
	if Input.is_action_pressed("ui_up"):
		v_y += jump(delta)
	
#	FIXME: make this v work
#	if Input.is_action_pressed("ui_attack") and can_attack:
#		current_weapon.attack()
#		$Cooldown_Root/LightAttack_CD.start()
#		can_attack = false
#	elif Input.is_action_pressed("special_attack") and can_attack:
#		$AnimationPlayer.play('special-attack')
#		$Cooldown_Root/SpecialAttack_CD.start()
#		can_attack = false
#	if Input.is_action_pressed('utility') and cooldowns['can_utility']:
#		$Cooldown_Root/Utility_CD.start()
#		cooldowns['can_utility'] = false
#		in_dash = true
#		yield(get_tree().create_timer(0.2), "timeout")
#		in_dash = false
#	if Input.is_action_pressed("debug_switch_weapon"):
#		switch_weapon()
	return Vector2(v_x, v_y)
	pass
	
func _physics_process(delta):
	if is_network_master():
		velocity.y += delta * GRAVITY
		if is_on_floor():
			velocity.y = 0
			jump_intensity = 0
			in_jump = false
		if is_on_ceiling():
			velocity.y = max(0, velocity.y)
		velocity = solve_input(delta)
		dash(delta) # TODO: maybe return a velocity.x from dash
		move_and_slide(velocity,Vector2(0, -1))
		rset("puppet_velocity", velocity)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_velocity
#	!! TODO: da deci pur si simplu de ce nu se animeaza
	solve_animation(velocity,delta)
	
	pass

sync func switch_weapon():
	pass
	
	
sync func out_of_bounds():
	pass
	
func _on_AnimatedSprite_animation_finished():
	pass

func _on_LightAttack_CD_timeout():
	pass

func _on_SpecialAttack_CD_timeout():
	pass

func _on_Utility_CD_timeout():
	pass
