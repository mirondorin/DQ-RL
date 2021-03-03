extends KinematicBody2D

export var SPEED = 100
export var JUMPSPEED = 80
onready var GRAVITY = get_node('../GlobalSettings').GRAVITY
var screen_size # Size of the game window
var velocity = Vector2()

var start_time = -100
var jump_intensity
var in_jump = false
var did_move = false
var landing = false

export var health = 100

var start_position = Vector2(91, 295) # aici e hardcodata, ar trebuii luata de undeva

func _ready():
	screen_size = get_viewport_rect().size

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

func solve_animation(velocity,delta):
	if velocity.x != 0:
		if $AnimationPlayer.current_animation != 'special-attack':
			$AnimatedSprite.flip_h = velocity.x < 0
			$Weapon.update_orientation(self)
			
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
	$Health.text = String(health)
	$AnimatedSprite.play()
	
	if health <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))

func on_gain_health():
	#if health >= 100:
	#	health = 100
	$Health.text = String(health)

func take_damage(value):
	health -= value
	on_lose_hp()

func gain_health(value):
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
		
	if Input.is_action_pressed("ui_attack"):
		$DebugAction.text = 'ATTACK'
		$Weapon.attack()
	if Input.is_action_pressed("special_attack"):
		$DebugAction.text = 'SPECIAL-ATTACK'
		$AnimationPlayer.play('special-attack')
	
func _physics_process(delta):
	velocity.y += delta * GRAVITY

	if is_on_floor():
		velocity.y=0
		jump_intensity = 0
		in_jump=false
	
	if is_on_ceiling():
		velocity.y=max(0,velocity.y)
		
	solve_animation(velocity,delta)
	solve_input(delta)
	# move_and_collide(velocity)
	move_and_slide(velocity,Vector2(0, -1))
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider.name == 'Mob':
			$DebugCollision.text = 'MOB'
		elif collision and collision.collider.name != 'Obstacles':
			$DebugCollision.text = collision.collider.name

func out_of_bounds():
	position = start_position


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation=='landing':
		landing=false
		$AnimatedSprite.play('walk')
	$AnimatedSprite.stop()
	pass # Replace with function body.
