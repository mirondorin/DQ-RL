extends Node

var mapstart = preload("res://Scenes/levels/level0.tscn")
var lobby = preload("res://Scenes/lobby.tscn")

var game_data = {}

var lobby_instance

func _ready():
#	var mapstart_instance = mapstart.instance()
#	add_child(mapstart_instance)
	lobby_instance = lobby.instance()
	add_child(lobby_instance)
	print(lobby_instance)
#	yield(get_tree().create_timer(1), "timeout")
#	Server.FetchGameData("a", get_instance_id())
	

func SetData(key, s_value):
	game_data[key] = s_value
	print(game_data)

