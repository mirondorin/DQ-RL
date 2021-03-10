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
	if Engine.is_editor_hint():
		if enemyscene != null:
			$Label.text = "spawner\n"+ enemyscene.get_path()
	else:
		$Label.queue_free()
		$CollisionShape2D.queue_free()
		
		$Timer.wait_time = spawn_delay
		if start_enabled:
			$Timer.start()
		
sync func spawn():
	if current_spawns < max_spawns or max_spawns == 0:
		var inst = enemy.instance()
		inst.spawner = self
		mainscene.add_child(inst)
		inst.position = self.position
		inst.velocity.x = 0
		inst.velocity.y = 0
		current_spawns += 1

sync func decrease_spawned():
	current_spawns -= 1

sync func start_spawner():
	$Timer.start()

sync func stop_spawner():
	$Timer.stop()

sync func _on_Timer_timeout():
	spawn()
	if spawn_continously:
		$Timer.start()
	
