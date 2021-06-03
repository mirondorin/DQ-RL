extends "res://scripts/DoorBase.gd"

var boss_spawner
var boss_alive = false

func _ready():
	boss_spawner = get_parent().get_node("EnemySpawner(Boss)")


sync func do_interact(initiator):
	.do_interact(initiator)
	if boss_spawner.enabled == true:
		if not is_network_master():
			return 1
		yield(get_tree().create_timer(1.0), "timeout") # Maybe change this
		if boss_spawner.current_spawns == 0:
			gamestate.change_level()
#			!! This is so laggy for peer in multiplayer. See what can be done!
#			!! This is so laggy for peer in multiplayer. See what can be done!
#			!! This is so laggy for peer in multiplayer. See what can be done!
#			!! This is so laggy for peer in multiplayer. See what can be done!
	elif voted_list.size() == player_num:
		boss_spawner.start_spawn()
		voted_list = []
		$VotesLabel.text = String(voted_list.size())

func interact(initiator):
	rpc("do_interact", initiator)
