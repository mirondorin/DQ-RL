tool
extends Node2D

onready var mainscene = get_parent()

export(PackedScene) var enemyscene
onready var enemy = load(enemyscene.get_path())
export var max_spawns = 3 #use 0 to spawn infinitely
export var use_timer = false
export var spawn_delay = 1

var current_spawns = 0

func _ready():
	if Engine.is_editor_hint():
		if enemyscene != null:
			$Label.text = "spawner\n"+ enemyscene.get_path()
	else:
		$Label.queue_free()
		
	$Timer.wait_time = spawn_delay
	if use_timer:
		$Timer.start()
		
func spawn():
	if current_spawns < max_spawns or max_spawns == 0:
		var inst = enemy.instance()
		inst.position = self.position
		mainscene.call_deferred("add_child",inst)
		current_spawns += 1

func start_spawner():
	$Timer.start()

func stop_spawner():
	$Timer.stop()

func _on_Timer_timeout():
	spawn()
	
