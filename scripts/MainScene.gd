extends Node


onready var level_root = get_node("LevelRoot")
onready var mobs_root = get_node("YSort/Mobs")
onready var other_players = get_node("YSort/OtherPlayers")


var player_spawn = preload("res://Scenes/Players/PlayableCharacterTemplate.tscn")
var mob = preload("res://scenes/Mobs/Mob.tscn")
var mob_projectile = preload("res://scenes/Mobs/MobProjectile.tscn")
var mob_homing_projectile = preload("res://scenes/Mobs/MobHomingProjectile.tscn")
var golem_boss = preload("res://scenes/Mobs/GolemBoss.tscn")


var current_level = 0
var last_worlds_state = 0
var player_list
var world_state_buffer = []
var interpolation_offset = 100


func _ready():
	change_level()


func get_new_enemy_instance(type):
	if type == "Mob":
		return mob.instance()
	if type == "MobProjectile":
		return mob_projectile.instance()
	if type == "MobHomingProjectile":
		return mob_homing_projectile.instance()
	if type == "GolemBoss":
		return golem_boss.instance()
	return mob.instance()


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
	yield(get_tree().create_timer(0.2), "timeout")
	print("Despawning player with id = " + str(player_id))
	if get_node("YSort/OtherPlayers/" + str(player_id)) != null:
		get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()
	else:
		print("some sort of error when despawning player, player does not exist")


func SpawnNewEnemy(enemy_id, enemy_dict):
	var new_enemy = get_new_enemy_instance(enemy_dict["type"])
	new_enemy.position = enemy_dict["pos"]
	new_enemy.ChangeStats(enemy_dict["stats"])
#	new_enemy.type = enemy_dict["type"]
	new_enemy.state = enemy_dict["state"]
	new_enemy.name = str(enemy_id)
	get_node("YSort/Mobs/").add_child(new_enemy, true)


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
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					var animation_data = world_state_buffer[2][player]["A"]
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_data)
				else:
					print("spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
			for enemy in world_state_buffer[2]["Enemies"].keys():
				if not world_state_buffer[1]["Enemies"].has(enemy):
					continue
				if get_node("YSort/Mobs").has_node(str(enemy)):
					var new_position = lerp(world_state_buffer[1]["Enemies"][enemy]["pos"], world_state_buffer[2]["Enemies"][enemy]["pos"], interpolation_factor)
					get_node("YSort/Mobs/" + str(enemy)).MoveEnemy(new_position)
					get_node("YSort/Mobs/" + str(enemy)).ChangeStats(world_state_buffer[1]["Enemies"][enemy]["stats"])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[2]["Enemies"][enemy])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position)
					
