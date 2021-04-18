extends Node


onready var level_root = get_node("LevelRoot")
onready var mobs_root = get_node("YSort/Mobs")
onready var other_players = get_node("YSort/OtherPlayers")


var player_spawn = preload("res://Scenes/Players/PlayableCharacterTemplate.tscn")


var current_level = 0
var last_worlds_state = 0
var player_list
var world_state_buffer = []
var interpolation_offset = 100


func _ready():
	change_level()
	

func change_level():
	print("Changing level")
	delete_current_mobs()
	var next_level = "level" + str(current_level) + ".tscn"
	var current_levels = level_root.get_children()
	if current_level != null:
		for i in current_levels:
			level_root.remove_child(current_level)
			i.queue_free()
	var new_level = load("res://scenes/levels/" + next_level).instance()
	level_root.add_child(new_level)
	print("New level loaded")


func delete_current_mobs():
	print("Deleting mobs")
	var current_mobs = mobs_root.get_children()
	if current_mobs == null:
		return 1
	while len(current_mobs) > 0:
		var mob = current_mobs[-1]
		mobs_root.remove_child(mob)
		mob.queue_free()


func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_node("YSort/OtherPlayers").has_node((str(player_id))):
			print("spawning new player with id = " + str(player_id))
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			other_players.add_child(new_player)


func DespawnPlayer(player_id):
	print("Despawning player with id = " + str(player_id))
	if get_node("YSort/OtherPlayers/" + str(player_id)) != null:
		get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()
	else:
		print("some sort of error when despawning player, player does not exist")


func start_game(s_spawn_positions):
	var my_id = get_tree().get_network_unique_id()
	get_node("YSort/PlayableCharacter").init_game_data()
	for player in s_spawn_positions.keys():
		if my_id == player:
			get_node("YSort/PlayableCharacter").set_player_name(s_spawn_positions[player]["name"])
			get_node("YSort/PlayableCharacter").set_start_position(s_spawn_positions[player]["pos"])
		elif get_node("YSort/OtherPlayers").has_node(str(player)):
			get_node("YSort/OtherPlayers/" + str(player)).set_player_name(s_spawn_positions[player]["name"])
			get_node("YSort/OtherPlayers/" + str(player)).set_start_position(s_spawn_positions[player]["pos"])
		else:
			var new_player = player_spawn.instance()
			new_player.set_start_position(s_spawn_positions[player]["pos"])
			new_player.name = str(player)
			new_player.set_player_name(s_spawn_positions[player]["name"])
			other_players.add_child(new_player)
	yield(get_tree().create_timer(1), "timeout")
	get_tree().paused = false
	get_node("YSort/PlayableCharacter").set_physics_process(true)
	print("Game started")


func update_world_state(s_world_state):
	if s_world_state["T"] > last_worlds_state:
		last_worlds_state = s_world_state["T"]
		world_state_buffer.append(s_world_state)


func _physics_process(delta):
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1].T:
			world_state_buffer.remove(0)
		var interpolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		for player in world_state_buffer[1].keys():
			if str(player) == "T":
				continue
			if player == get_tree().get_network_unique_id():
				continue
			if not world_state_buffer[0].has(player):
				continue
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				var new_position = lerp(world_state_buffer[0][player]["P"], world_state_buffer[1][player]["P"], interpolation_factor)
				get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position)
			else:
				print("spawning player")
				SpawnNewPlayer(player, world_state_buffer[1][player]["P"])
