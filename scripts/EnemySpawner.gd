tool
extends Node2D

onready var mainscene = get_parent()

export (PackedScene) var enemyscene
onready var enemy = load(enemyscene.get_path())
export var max_spawns = 2 #use 0 to spawn infinitely
export var start_enabled = false
export var spawn_delay = 1
export var spawn_continously = false

var current_spawns = 0
var enabled = false

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
			enabled = true


sync func do_spawn():
	var inst = enemy.instance()
#	maybe we should set a name for mobs?
	inst.spawner = self
	mainscene.add_child(inst)
	inst.position = self.position
	inst.velocity.x = 0
	inst.velocity.y = 0
	current_spawns += 1
	pass

func spawn():
	if current_spawns < max_spawns or max_spawns == 0:
		rpc("do_spawn")
	pass

func start_spawn():
	if enabled == false:
		$Timer.start()
		enabled = true

# V 02. sync
# Godot docs say that "Use sync because it will be called everywhere"
# I don't think sync works, try remotesync
#func spawn():
#	if current_spawns < max_spawns or max_spawns == 0:
#		var inst = enemy.instance()
#		inst.spawner = self
#		mainscene.add_child(inst)
#		inst.position = self.position
#		inst.velocity.x = 0
#		inst.velocity.y = 0
#		current_spawns += 1

func decrease_spawned():
	current_spawns -= 1
	pass

func start_spawner():
	$Timer.start()


func stop_spawner():
	$Timer.stop()

func _on_Timer_timeout():
	if is_network_master():
		spawn()
	
	if spawn_continously:
		$Timer.start()
	else:
		$Timer.stop()
	
