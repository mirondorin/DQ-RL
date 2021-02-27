extends KinematicBody2D

export var SPEED = 100
export var JUMPSPEED = 80
const GRAVITY = 500.0
var velocity = Vector2()
onready var player = $'../PlayableCharacter'
var follow = false
var direction = 1

var time_start = 0
var time_now = 0

func attack_cooldown():
	if time_now - time_start == 2:
		follow = true
		return true
	follow = false
	return false

func flip_sprite(velocity_x):
	if velocity_x != 0:
		$AnimatedSprite.flip_h = velocity_x < 0

func follow_player():
	if position.x < player.position.x:
		direction = 1
	else:
		direction = -1
	
	if not follow and not attack_cooldown():
		direction = 0
	else:
		time_start = 0
		time_now = 0

func _physics_process(delta):
	time_now = OS.get_unix_time()
	
	follow_player()
	flip_sprite(velocity.x)
	velocity.y += delta * GRAVITY
	velocity.x = SPEED * direction
	
	if is_on_floor():
		velocity.y=0
		var jump_intensity = 0
		var in_jump=false
	
	if is_on_ceiling():
		velocity.y=max(0,velocity.y)
	
	#solve_animation(velocity,delta)
	#move_and_collide(velocity)
	
	move_and_slide(velocity, Vector2(0, -1))
		
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision and collision.collider.name == 'PlayableCharacter' and follow:
			move_and_slide(Vector2(velocity.x + 2000*direction*-1, velocity.y), Vector2(0, -1))
			time_start = OS.get_unix_time()
			follow = false

func _on_DetectArea_body_entered(body):
	if body == player:
		follow = true

func _on_DetectArea_body_exited(body):
	if body == player:
		follow = false
