extends Node2D

func _ready():
	pass

sync func do_interact():
#	if is_network_master():
#		gamestate.change_level()
	pass

func interact():
	rpc("do_interact")
