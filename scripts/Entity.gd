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

var animation_play = false
var animation_stop = false
var animation_change = false
var animation_dict = {}
var animation_play_what = ""

var stats = {
	"health" : 100,
	"stagger_default" : 10,
	"stagger_health" : 10,
	"invincible" : false,
	"default_speed": 100
}

func get_x_orientation():
	if $AnimatedSprite.flip_h:
		return -1
	return 1

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
	else:
		impulse_current_x = 0
		impulse_dir.x = 0
	
	if impulse_current_y > 0:
		impulse_current_y -= impulse_step
	else:
		impulse_current_y = 0
		impulse_dir.y = 0
		
#	if impulse_current_x <= 0 and impulse_current_y <= 0:
	if impulse_current_x == 0 and impulse_current_y == 0:
		impulse_step = 5
		in_impulse = false
	
func take_damage(value, stagger, direction, impulse_force):
	if not stats['invincible'] and is_network_master():
		rpc("do_take_damage", value, stagger, direction, impulse_force)

sync func do_take_damage(value, stagger, direction, impulse_force):
	stats['health'] -= value
	stats['stagger_health'] -= stagger
	on_take_damage(direction, impulse_force)
	
func on_take_damage(direction, impulse_force):
	if stats['stagger_health'] <= 0:
		animation_dict["animation"] = "hit"
		animation_change = true
		stats['stagger_health'] = stats['stagger_default']
	$Health.text = String(stats['health'])
	animation_play = true
	animation_play_what = ""
	if stats['health'] <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))
	pass

func out_of_bounds():
	queue_free()
	
sync func set_entity_position(pos, v):
	position = pos 
	velocity = v  # do we really need to sync velocity?
#	TODO: try to not sync velocity or position

sync func do_change_animation(animation_dict):
	for what in animation_dict.keys():
		$AnimatedSprite[what] = animation_dict[what]
	
func change_animation():
	animation_change = false
	rpc_unreliable("do_change_animation", animation_dict)
	animation_dict = {}

sync func do_play_animation(what):
	$AnimatedSprite.play(what)

func play_animation():
	animation_play = true
	rpc_unreliable("do_play_animation", animation_play_what)
	
sync func do_stop_animation():
	$AnimatedSprite.stop()
	
func stop_animation():
	animation_stop = false
	rpc_unreliable("do_stop_animation")

func make_animation_calls():
	if is_network_master(): # ? Redundand if?
		if animation_stop:
			stop_animation()
		elif animation_play:
			play_animation()
		if animation_change:
			change_animation()
