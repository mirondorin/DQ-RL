extends "res://scripts/Players/PlayableCharacter.gd"


func _ready():
	pass # Replace with function body.


func MovePlayer(new_position, animation_data):
	animation_stop = animation_data["animation_stop"]
	animation_stopped = animation_data["animation_stopped"]
	animation_play = animation_data["animation_play"]
	old_animation_play_what = animation_data["old_animation_play_what"]
	animation_play_what = animation_data["animation_play_what"]
	animation_change = animation_data["animation_change"]
	new_animation_dict = animation_data["new_animation_dict"]
	position = new_position


func set_player_name(new_name):
	$DebugAction.text = new_name


func set_start_position(pos):
	position = pos
	start_position = pos


func _physics_process(delta):
	make_animation_calls()

