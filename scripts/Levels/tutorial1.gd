extends Node2D

var players
var mobs = []
var MobStaticpos
var finishedmovement = false
var finishedfightarea1 = false
onready var currentrespawn = $Triggers/respawn1
const health = preload("res://scenes/items/HealthPickup.tscn")

func _ready():
	MobStaticpos = $MobStatic.position
	$MobStatic.stats['health'] = 99999
	
func _process(delta):
	for player in players:
		if player.stats['health'] <= 0:
			if finishedmovement:
				currentrespawn = $Triggers/respawn2
			player.position = currentrespawn.position
			player.stats['health'] = 10
			

func _on_StartTrigger_area_entered(area):
	players = get_tree().get_nodes_in_group('players')
	for player in players:
		player.stats['health'] = 10
	$Triggers/StartTrigger/CollisionShape2D.disabled = true
	

func _on_respawntrigger0_area_entered(area):
	area.get_parent().position = $Triggers/respawn0.position

func _on_respawntrigger1_area_entered(area):
	area.get_parent().position = $Triggers/respawn1.position

func _on_fightareatrigger_area_entered(area):
	finishedmovement = true
	print('asasd')

func _on_MobSpawnArea_area_entered(area):
	mobs.append(area.get_parent())
