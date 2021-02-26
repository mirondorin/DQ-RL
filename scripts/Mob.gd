extends KinematicBody2D

export var SPEED = 100
export var JUMPSPEED = 80
const GRAVITY = 500.0
var velocity = Vector2()
onready var player = $'../PlayableCharacter'

func walk(velocity_x):
	if velocity_x != 0:
		$AnimatedSprite.flip_h = velocity_x < 0

func follow_player(velocity):
	print(player.position)

func _physics_process(delta):
	follow_player(velocity)
	velocity.y += delta * GRAVITY

	if is_on_floor():
		velocity.y=0
		var jump_intensity = 0
		var in_jump=false
	
	if is_on_ceiling():
		velocity.y=max(0,velocity.y)
		
	velocity.x = -SPEED
	
	walk(velocity.x)
#	solve_animation(velocity,delta)
	# move_and_collide(velocity)
	move_and_slide(velocity,Vector2(0, -1))
	for i in get_slide_count():
		var collision = get_slide_collision(i)
#		if collision and collision.collider.name != 'Obstacles':
#			print("MOB Collided with: ", collision.collider.name)
