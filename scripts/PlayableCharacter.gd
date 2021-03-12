extends KinematicBody2D

onready var current_weapon = $Weapon

export var SPEED = 100
export var JUMPSPEED = 80
onready var GRAVITY = get_node('../GlobalSettings').GRAVITY
export var air_resistance_factor = 11
export var collision_resistance_factor = 3

var screen_size # Size of the game window
var velocity = Vector2()

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

var start_position
var stats = {
	"damage_modifier" : 0,
	"health" : 100
}

var x_direction = 0

func _ready():
	screen_size = get_viewport_rect().size
	start_position = position

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

func dash(delta):
	var dir = -1 if $AnimatedSprite.flip_h else 1
	self.GRAVITY = 0
	velocity.y = 0
	impulse(500, Vector2(dir, -0.001), 10, false)

func solve_animation(velocity,delta):
	if $AnimationPlayer.current_animation != 'special-attack':
		if x_direction < 0:
			$AnimatedSprite.flip_h = true
		elif x_direction > 0:
			$AnimatedSprite.flip_h = false
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

func on_lose_hp():
	$AnimatedSprite.animation='hit'
	$Health.text = String(stats['health'])
	$AnimatedSprite.play()
	
	if stats['health'] <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))

func update_health():
	#if health >= 100:
	#	health = 100
	$Health.text = String(stats['health'])

func take_damage(value):
	stats['health'] -= value
	on_lose_hp()

func solve_input(delta):
	$DebugAction.text = 'action'
	
	if Input.is_action_pressed("ui_left"):
		x_direction = -1
	elif Input.is_action_pressed("ui_right"):
		x_direction = 1
	else:
		x_direction = 0
	
	print(x_direction)
		
	if Input.is_action_pressed("ui_up"):
		if not in_impulse:
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
		dash(delta)
		yield(get_tree().create_timer(0.2), "timeout")
		self.GRAVITY = get_node('../GlobalSettings').GRAVITY
		in_dash = false
		self.impulse_current_x = impulse_current_x/3
		self.impulse_step = 5
	if Input.is_action_just_pressed("debug_test"): 
		var dir = (self.position - get_global_mouse_position()).normalized() * -1
		impulse(400, dir)
		
	if Input.is_action_just_pressed("debug_switch_weapon"):
		switch_weapon()

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
	velocity.y += delta * GRAVITY
	solve_impulse()
	
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

	solve_animation(velocity,delta)
	solve_input(delta)
	#dash(delta)
		
	velocity.x = x_direction * SPEED + impulse_dir.x * impulse_current_x
	var vel_y = velocity.y + impulse_dir.y * impulse_current_y
	var vel = Vector2(velocity.x, vel_y)

	move_and_slide(vel, Vector2(0, -1))
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider.name == 'Mob':
			$DebugCollision.text = 'MOB'
		elif collision and collision.collider.name != 'Obstacles':
			$DebugCollision.text = collision.collider.name

var weapon = 0 # Delete this later. Only for debug
func switch_weapon():
	weapon = 1 - weapon
	current_weapon.queue_free()
	var wep
	if weapon == 1:
		wep = load("res://scenes/WeaponProjectile.tscn")
	else:
		wep = load("res://scenes/Weapon.tscn")
	var inst = wep.instance()
	current_weapon = inst
	add_child(inst)
	
	
func out_of_bounds():
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

func grab_item():
	print("Called grab item")

func modify_stats(status, value):
	stats[status] += value
	update_health()
