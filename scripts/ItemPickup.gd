extends Node2D

export var value = 10
export var one_time = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.name == 'PlayableCharacter':
		body.gain_health(10)
		if one_time:
			queue_free()
