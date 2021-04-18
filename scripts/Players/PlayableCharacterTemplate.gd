extends KinematicBody2D


var start_position


func _ready():
	pass # Replace with function body.

func MovePlayer(new_position):
	set_position(new_position)


func set_player_name(new_name):
	$DebugAction.text = new_name


func set_start_position(pos):
	position = pos
	start_position = position
