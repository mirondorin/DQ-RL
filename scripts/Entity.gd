extends KinematicBody2D

export var SPEED = 100
export var JUMPSPEED = 80
onready var GRAVITY = get_tree().get_root().get_node('MainScene/GlobalSettings').GRAVITY

export var air_resistance_factor = 11
export var collision_resistance_factor = 3

var impulse_current_x = 0
var impulse_current_y = 0
var impulse_dir = Vector2(0, 0)
var in_impulse = false
var impulse_step = 5

var x_direction = 0
var velocity = Vector2()

var stats = {
	"health" : 100
}

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
	
func take_damage(value):
	stats['health'] -= value
	on_lose_hp()

func on_lose_hp():
#	animate("animation", "hit")
	$Health.text = String(stats['health'])
#	play_animation("")
	if stats['health'] <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))
	pass
