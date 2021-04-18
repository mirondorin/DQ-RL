extends Node

var mapstart = preload("res://Scenes/levels/level0.tscn")
var lobby = preload("res://Scenes/lobby.tscn")
var main_scene = preload("res://Scenes/MainScene.tscn")

var mainscene_instance
var game_data = {}
var lobby_instance

func _ready():
	mainscene_instance = main_scene.instance()
	add_child(mainscene_instance)
	lobby_instance = lobby.instance()
	add_child(lobby_instance)
	print(lobby_instance)
	get_tree().paused = true
#	yield(get_tree().create_timer(1), "timeout")
#	Server.FetchGameData("a", get_instance_id())
	

func SetData(s_value):
	game_data = s_value
	print(game_data)


func FetchGameData():
	Server.FetchGameData(get_instance_id())


func change_level():
	print("Trying to change level")
