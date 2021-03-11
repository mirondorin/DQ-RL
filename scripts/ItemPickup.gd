extends Node2D

export var value = 10
export var one_time = true
export var status_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


puppet func do_be_picked(body):
	body.gain_health(10)
	pass

master func be_picked(body):
#	rpc("do_be_picked", body) # ! Not working because rpc calls for every player
	do_be_picked(body)
	pass


#func _on_Area2D_body_entered(body):
#	if body.has_method("gain_health"): # maybe replace this with sth else, even though it's good enough as it is
#		be_picked(body)
func _on_Area2D_body_entered(body):
	if body.name == 'PlayableCharacter':
		body.modify_stats(status_name, value)
		if one_time:
			queue_free()
		pass
	pass
