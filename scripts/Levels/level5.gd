extends Node2D


var boss = []
var nr_bosses = 2
onready var door=$NewLevelDoor
onready var label=$Label

func _ready():
	for i in range(0,nr_bosses):
		boss.append(get_node("EnemySpawner"+String(i+1)))
	door.visible=false
	label.visible=false
	pass

func _process(delta):
	for i in range(0,nr_bosses):
		if(boss[i].current_spawns!=0 or boss[i].total_spawns!=0):
			return 
	door.visible=true
	label.visible=true
