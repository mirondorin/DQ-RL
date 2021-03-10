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
var start_position

func set_player_name(new_name):
	name = new_name

func _ready():
	screen_size = get_viewport_rect().size
	start_position = position
	player_pos = position

sync func jump(time):
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

sync func dash(delta):
	if not in_dash:
		return
	var direction = 0
	if velocity.x != 0:
		direction = 1 if velocity.x > 0 else -1
	else:
		direction = 1 if $AnimatedSprite.flip_h == false else -1
	velocity.x += 400 * direction

sync func solve_animation(velocity,delta):
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

sync func on_lose_hp():
	$AnimatedSprite.animation='hit'
	$Health.text = String(health)
	$AnimatedSprite.play()
	
	if health <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))

sync func on_gain_health():
	#if health >= 100:
	#	health = 100
	$Health.text = String(health)

sync func take_damage(value):
	health -= value
	on_lose_hp()

sync func gain_health(value):
	health += value
	on_gain_health()

func solve_input(delta):
	$DebugAction.text = 'action'
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  SPEED
	else:
		velocity.x=0
	if Input.is_action_pressed("ui_up"):
		velocity.y += jump(delta)
		
	if Input.is_action_pressed("ui_attack") and can_attack:
		$DebugAction.text = 'ATTACK'
		current_weapon.attack()
		$Cooldown_Root/LightAttack_CD.start()
		can_attack = false
	elif Input.is_action_pressed("special_attack") and can_attack:
		$DebugAction.text = 'SPECIAL-ATTACK'
		$AnimationPlayer.play('special-attack')
		$Cooldown_Root/SpecialAttack_CD.start()
		can_attack = false
	if Input.is_action_pressed('utility') and cooldowns['can_utility']:
		$DebugAction.text = 'UTILITY'
		$Cooldown_Root/Utility_CD.start()
		cooldowns['can_utility'] = false
		in_dash = true
		yield(get_tree().create_timer(0.2), "timeout")
		in_dash = false
	if Input.is_action_pressed("debug_switch_weapon"):
		switch_weapon()
	
func _physics_process(delta):
	if is_network_master():
		velocity.y += delta * GRAVITY

		if is_on_floor():
			velocity.y=0
			jump_intensity = 0
			in_jump=false
	
		if is_on_ceiling():
			velocity.y=max(0,velocity.y)
	
		solve_input(delta)
		dash(delta)
		move_and_slide(velocity,Vector2(0, -1))
		
		rset("puppet_velocity", velocity)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		velocity = puppet_velocity
	
	solve_animation(velocity,delta)
	for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision and collision.collider.name == 'Mob':
				$DebugCollision.text = 'MOB'
			elif collision and collision.collider.name != 'Obstacles':
				$DebugCollision.text = collision.collider.name
	
	if not is_network_master():
		puppet_pos = position

sync func switch_weapon():
	current_weapon.queue_free()
	var projwep = load("res://scenes/WeaponProjectile.tscn")
	var inst = projwep.instance()
	current_weapon = inst
	add_child(inst)
	
	
sync func out_of_bounds():
	position = start_position
	
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation=='landing':
		landing=false
		$AnimatedSprite.play('walk')
	$AnimatedSprite.stop()
	pass # Replace with function body.

func _on_LightAttack_CD_timeout():
	can_attack = true

func _on_SpecialAttack_CD_timeout():
	can_attack = true

func _on_Utility_CD_timeout():
	cooldowns['can_utility'] = true
