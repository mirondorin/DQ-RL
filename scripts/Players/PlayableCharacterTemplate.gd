extends KinematicBody2D


func _ready():
	pass # Replace with function body.

func MovePlayer(new_position):
	print("Moving other player")
	set_position(new_position)
