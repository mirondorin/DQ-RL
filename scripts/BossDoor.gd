extends Node2D

var boss_spawner
var boss_alive = false

func _ready():
	boss_spawner = get_parent().get_node("EnemySpawner(Boss)")

func interact():
	if boss_spawner.enabled == true:
		yield(get_tree().create_timer(1.0), "timeout")
		if boss_spawner.current_spawns == 0:
			gamestate.change_level()
	else:
		boss_spawner.start_spawn()
