extends KinematicBody2D

var spawner = null

export var SPEED = 90
export var JUMPSPEED = 320
onready var GRAVITY = $'../GlobalSettings'.GRAVITY
onready var player = $'../Players/PlayableCharacter'
onready var attack_timer = $'AttackCooldown'
onready var jump_timer = $'JumpCooldown'
export var health = 20
puppet var puppet_health

var is_dead = false

var velocity = Vector2()
export var follow = true

puppet var puppet_velocity = Vector2()
puppet var puppet_pos = Vector2()

var direction = 1
var in_jump = false
var can_jump = false
var can_attack = true
var jump_intensity = 0
var start_time = -100
var attack_damage = 10
var attack_cooldown = 1.5	
var jump_cooldown = 4

var in_area = []

func _ready():
	pass

	
sync func jump(time):
	pass

sync func follow_player():
	pass

sync func attack_player(collider):
	pass

sync func solve_animation(velocity,delta):
	pass

sync func out_of_bounds():
	pass
	
func _physics_process(delta):
	pass

sync func on_take_damage():
	pass

sync func take_damage(value):
	pass

func _on_DetectArea_body_entered(body):
	pass

func _on_DetectArea_body_exited(body):
	pass

func _on_AttackCooldown_timeout():
	pass
	
func _on_JumpCooldown_timeout():
	pass
