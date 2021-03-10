extends Node2D

export var value = 10
export var one_time = true
export var status_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if body.name == 'PlayableCharacter':
		body.modify_stats(status_name, value)
		if one_time:
			queue_free()
