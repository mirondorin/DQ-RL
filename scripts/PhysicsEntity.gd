extends KinematicBody2D

export var SPEED = 100
export var JUMPSPEED = 80
onready var GRAVITY = GlobalSettings.GRAVITY

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
var animation_stopped = false
var animation_change = false
var animation_dict = {}
var new_animation_dict = {}
var animation_play_what = ""
var old_animation_play_what = "1"

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

func out_of_bounds():
	queue_free()


sync func set_entity_position(pos):
	position = pos 


sync func do_change_animation(new_animation_dict):
	for what in new_animation_dict.keys():
		$AnimatedSprite[what] = new_animation_dict[what]
	
func change_animation():
	animation_change = false
	rpc_unreliable("do_change_animation", new_animation_dict)
	new_animation_dict = {}

sync func do_play_animation(what):
	$AnimatedSprite.play(what)

func play_animation():
	animation_play = true
	animation_stopped = false
	old_animation_play_what = animation_play_what
	rpc_unreliable("do_play_animation", animation_play_what)
	
sync func do_stop_animation():
	$AnimatedSprite.stop()
	
func stop_animation():
#	TODO: check if this doesn't affect animation_dict
	animation_stop = false
	animation_stopped = true
	old_animation_play_what = "1"
	rpc_unreliable("do_stop_animation")

func make_animation_calls():
	if is_network_master(): # ? Redundant if?
		if animation_stop and not animation_stopped:
			stop_animation()
		elif animation_play and old_animation_play_what != animation_play_what:
			play_animation()
		if animation_change:
			change_animation()

func key_has_value(dictionary, key, value):
	if key in dictionary.keys():
		return dictionary[key] == value
	return false
