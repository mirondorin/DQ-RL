extends Node


const DEFAULT_PORT = 10567
const MAX_PEERS = 12


var peer = null

var player_name = "The Warrior"
var first_level : bool = true


var players = {}
var players_ready = []


signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)


func _player_connected(id):
	rpc_id(id, "register_player", player_name)


func _player_disconnected(id):
	if has_node("/root/MainScene"):
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: 
		unregister_player(id)


func _connected_ok():
	emit_signal("connection_succeeded")


func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print("New player registered: " + str(id) + " : " + str(new_player_name))
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	print("Player disconnected: " + str(id))
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(spawn_points):
	var world = load("res://scenes/MainScene.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://scenes/PlayableCharacter.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("LevelRoot/Spawn/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()
		player.set_name(str(p_id))
		player.position = spawn_pos
		player.set_network_master(p_id)
		if p_id == get_tree().get_network_unique_id():
			player.set_player_name(player_name)
		else:
			player.set_player_name(players[p_id])
		world.get_node("Players").add_child(player)
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!
	if first_level:
		get_node("/root/MainScene/LevelRoot/NewLevelDoor").reinit() # reinit new level door
		first_level = false
	


remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	if not id in players_ready:
		players_ready.append(id)
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func get_player_list():
	return players.values()


func get_player_dict():
	return players

func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())
	var spawn_points = {}
	spawn_points[1] = 0 
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)
	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): 
		get_node("/root/World").queue_free()
	emit_signal("game_ended")
	players.clear()


remote func peer_change_level(spawn_points):
	get_tree().call_group("projectile", "queue_free")	
	var world = get_tree().get_root().get_node("MainScene")
	GlobalSettings.level_nr += 1
	var lvl_nr = GlobalSettings.level_nr
	if lvl_nr>=6:
		lvl_nr= (lvl_nr-1)%5+1
	var level = world.get_node("LevelRoot")
	var next_level = "level" + str(lvl_nr) + ".tscn"
	world.remove_child(level)
	level.queue_free()
	level = load("res://scenes/levels/" + next_level).instance()
	world.add_child(level)
	for p_id in spawn_points:
		var spawn_pos = world.get_node("LevelRoot/Spawn/" + str(spawn_points[p_id])).position
		var player = world.get_node("Players/" + str(p_id))
		if player != null:
			player.modify_stats("health",player.stats["max_health"] - player.stats["health"])
		player.position = spawn_pos
	world.move_child(world.get_node("Players"), world.get_child_count())
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


sync func master_change_level():
	var world = get_tree().get_root().get_node("MainScene")
	world.remove_all_mobs()
	get_tree().set_pause(true)
	if not get_tree().is_network_server():
		return 1
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	for p in players:
		rpc_id(p, "peer_change_level", spawn_points)
	peer_change_level(spawn_points)


func change_level():
	print("change level")
	rpc("master_change_level")
	
func set_character_index(new_name, index):
	#GlobalSettings.player_sprite_type[new_name] = index
	rpc("remote_set_char", new_name, index)

sync func remote_set_char(new_name, index):
	GlobalSettings.player_sprite_type[new_name] = index
	print(GlobalSettings.player_sprite_type)


func sync_player_sprites_with_master():
	rpc("do_sync_player_sprites_with_master", GlobalSettings.player_sprite_type)


sync func do_sync_player_sprites_with_master(master_player_sprites):
	GlobalSettings.player_sprite_type = master_player_sprites


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
