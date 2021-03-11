tool
extends Node2D

onready var mainscene = get_parent()

export(PackedScene) var enemyscene
onready var enemy = load(enemyscene.get_path())
export var max_spawns = 3 #use 0 to spawn infinitely
export var start_enabled = false
export var spawn_delay = 1
export var spawn_continously = false

var current_spawns = 0

func _ready():
	pass
		
sync func spawn():
	pass

sync func decrease_spawned():
	pass

sync func start_spawner():
	pass

sync func stop_spawner():
	pass

sync func _on_Timer_timeout():
	pass
	
