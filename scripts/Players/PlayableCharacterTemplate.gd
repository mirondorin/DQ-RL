extends KinematicBody2D


var start_position : int
var animation_stop : bool
var animation_play : String
var animation_dict : Dictionary


func _ready():
	pass # Replace with function body.


func MovePlayer(new_position, animation_data):
	set_position(new_position)
	set_animation(animation_data)


func set_position(pos):
	position = pos


func set_animation(animation_data):
	animation_stop = animation_data["animation_stop"]
	animation_play = animation_data["animation_play"]
	animation_dict = animation_data["animation_dict"]


func set_player_name(new_name):
	$DebugAction.text = new_name


func set_start_position(pos):
	position = pos
	start_position = pos


func _physics_process(delta):
	make_animation_calls()


func make_animation_calls():
	if animation_stop:
		stop_animation()
	elif animation_play != "None":
		play_animation(animation_play)
		animation_play = "None"
	change_animation(animation_dict)


func stop_animation():
	$AnimationPlayer.stop()


func play_animation(what):
	$AnimationPlayer.play(what)


func change_animation(animation_dict):
	for key in animation_dict.keys():
		$AnimationPlayer[key] = animation_dict[key]

