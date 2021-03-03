extends KinematicBody2D

export var SPEED = 90
export var JUMPSPEED = 80
onready var GRAVITY = get_node('../GlobalSettings').GRAVITY
onready var player = $'../PlayableCharacter'
onready var attack_timer = $'AttackCooldown'

export var health = 20

var velocity = Vector2()
export var follow = true
var direction = 1

var attack_damage = 10
var attack_cooldown = 1.5	
	
func _ready():
	attack_timer.wait_time = attack_cooldown	
	

func follow_player():
	
	if position.x < player.position.x:
		direction = 1
	else:
		direction = -1
	
	if not follow:
		direction = 0

func attack_player(collider):
	collider.call("take_damage", attack_damage)
	move_and_slide(Vector2(velocity.x + 2000*direction*-1, velocity.y), Vector2(0, -1))
	follow = false
	attack_timer.start()

func solve_animation(velocity,delta):
	if velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.animation = 'walk'
	
	if velocity.x == 0:
		$AnimatedSprite.animation = 'idle'

func out_of_bounds():
	# we can add invisible objects, boundaries, and 
	# _on_Area2D_body_entered => direction *= -1
	# to ensure that the enemy patrols only one zone
	get_node("../EnemySpawner").spawn() #remove this
	queue_free()
	
func _physics_process(delta):
	follow_player()
	# delete_if_falling()
	velocity.y += delta * GRAVITY
	velocity.x = SPEED * direction
	solve_animation(velocity, delta)
	
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
			attack_player(collision.collider)
			

func on_take_damage():
	if health > 0:
		$HealthLabel.text = String(health)
	else:
		get_node("../EnemySpawner").spawn() #remove this
		queue_free()
	
	follow = false
	attack_timer.start()

func take_damage(value):
	health -= value
	on_take_damage()

func _on_DetectArea_body_entered(body):
	if body == player:
		follow = true

func _on_DetectArea_body_exited(body):
	if body == player:
		follow = false

func _on_AttackCooldown_timeout():
	follow = true
