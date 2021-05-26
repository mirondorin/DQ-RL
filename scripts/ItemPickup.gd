extends Node2D

export var value = 10
export var one_time = true
export var status_name = ""

func _ready():
	pass 
	
func pickup_sfx():
	var target = get_tree().get_root().get_node("MainScene/GlobalSounds")
	var source = $pickupsound
	self.remove_child(source)
	target.add_child(source)
	source.play()

func _on_Area2D_body_entered(body):
	if body.is_in_group("players"):
		body.modify_stats(status_name, value)
		pickup_sfx()
		if one_time:
			queue_free()
