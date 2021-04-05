extends Node2D

func _ready():
	pass

sync func do_interact():
	gamestate.change_level()

func interact():
	rpc("do_interact")
