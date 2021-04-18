extends Node


onready var level_root = get_node("LevelRoot")
onready var mobs_root = get_node("YSort/Mobs")
onready var other_players = get_node("YSort/OtherPlayers")


var player_spawn = preload("res://Scenes/Players/PlayableCharacterTemplate.tscn")


var current_level = 0
var last_worlds_state = 0


func _ready():
	change_level()
	

func change_level():
	delete_current_mobs()
	print("Deleted mobs")
	var next_level = "level" + str(current_level) + ".tscn"
	var current_levels = level_root.get_children()
	if current_level != null:
		for i in current_levels:
			level_root.remove_child(current_level)
			i.queue_free()
	var new_level = load("res://scenes/levels/" + next_level).instance()
	level_root.add_child(new_level)


func delete_current_mobs():
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


func start_game():
	get_tree().paused = false
	get_node("YSort/PlayableCharacter").init_game_data()
	get_node("YSort/PlayableCharacter").set_physics_process(true)
	print("Game started")


func update_world_state(s_world_state):
	if s_world_state["T"] > last_worlds_state:
		last_worlds_state = s_world_state["T"]
		s_world_state.erase("T")
		s_world_state.erase(get_tree().get_network_unique_id())
		for player in s_world_state.keys():
			if get_node("YSort/OtherPlayers").has_node(str(player)):
				get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(s_world_state[player]["P"])
			else:
				print("spawning player")
				SpawnNewPlayer(player, s_world_state[player]["P"])
