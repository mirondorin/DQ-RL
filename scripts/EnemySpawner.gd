tool
extends Node2D

onready var mainscene = get_parent()

export (PackedScene) var enemyscene
export (String) var mob_type
onready var enemy = load(enemyscene.get_path())
export var max_spawns = 2 #use 0 to spawn infinitely
export var start_enabled = true
export var spawn_delay = 1
export var spawn_continously = false

var current_spawns = 0
var enabled = false
var cleanup = true
var mob_health


func _init():
	mob_health = 25 # viata se face in functie de level in main_scene, unde se adauga mob-ul


func tool_cleanup():
	if Engine.is_editor_hint():
		if enemyscene != null:
			$Label.text = "spawner\n"+ enemyscene.get_path()
	else:
		$Label.queue_free()
		$CollisionShape2D.queue_free()

func _ready():
	if cleanup:
		tool_cleanup()
		
	$Timer.wait_time = spawn_delay
	if start_enabled:
		$Timer.start()
		enabled = true


func do_spawn():
	get_parent().get_parent().add_new_mob(mob_type, mob_health, self.position)
	current_spawns += 1


func spawn():
	if current_spawns < max_spawns or max_spawns == 0:
		do_spawn()


func start_spawn():
	if enabled == false:
		$Timer.start()
		enabled = true


func decrease_spawned():
	current_spawns -= 1


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
	
