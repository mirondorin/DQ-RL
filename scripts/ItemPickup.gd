extends Node2D

export var value = 10
export var one_time = true
export var status_name = ""

func _ready():
	pass 

func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		body.modify_stats(status_name, value)
		if one_time:
			queue_free()
