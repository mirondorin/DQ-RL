extends KinematicBody2D


export var SPEED = 100
export var JUMPSPEED = 80
export var air_resistance_factor = 11
export var collision_resistance_factor = 3


onready var scene_handler = get_tree().get_root().get_node("SceneHandler")


var impulse_current_x = 0
var impulse_current_y = 0
var impulse_dir = Vector2(0, 0)
var in_impulse = false
var impulse_step = 5


var x_direction = 0
var velocity = Vector2()


var animation_play : String = "None"
var animation_stop : bool = false
var animation_dict : Dictionary = {}


var GRAVITY = 500.0


func init_gravity():
	if scene_handler.game_data.has("GRAVITY"):
		GRAVITY = scene_handler.game_data["GRAVITY"]
	else:
		GRAVITY = 500.0


func _ready():
	yield(get_tree().create_timer(1.0), "timeout")
	init_gravity()


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
	
func set_entity_position(pos, v):
	position = pos 
	velocity = v  # do we really need to sync velocity?
#	TODO: try to not sync velocity or position

func do_change_animation(new_animation_dict):
	for what in new_animation_dict.keys():
		$AnimatedSprite[what] = new_animation_dict[what]


func change_animation():
	do_change_animation(animation_dict)


func do_play_animation(what):
	$AnimatedSprite.play(what)


func play_animation():
	do_play_animation(animation_play)
	animation_play = "None"

	
sync func do_stop_animation():
	$AnimatedSprite.stop()


func stop_animation():
	animation_stop = false
	do_stop_animation()


func make_animation_calls():
	if animation_stop:
		stop_animation()
	if animation_play != "None":
		play_animation()
	change_animation()


func key_has_value(dictionary, key, value):
	if key in dictionary.keys():
		return dictionary[key] == value
	return false
