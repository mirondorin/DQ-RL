extends Node2D


var boss_spawner
var boss_alive = false


func _ready():
	boss_spawner = get_parent().get_node("EnemySpawner(Boss)")


func do_interact():
	if boss_spawner.enabled == true:
		yield(get_tree().create_timer(1.0), "timeout") # Maybe change this
		if boss_spawner.current_spawns == 0:
			print("To change level")
	else:
		boss_spawner.start_spawn()


func interact():
	do_interact()
