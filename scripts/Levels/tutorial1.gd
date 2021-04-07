extends Node2D

var players
var mobs = []
var MobStaticpos
var finishedmovement = false
var finishedfightarea1 = false
var respawnhealth = 10
onready var currentrespawn = $respawn0

func _ready():
	MobStaticpos = $MobStatic.position
	$MobStatic.stats['health'] = 99999
	
func _process(delta):
	for player in players:
		if player.stats['health'] <= 0:
			player.position = currentrespawn.position
			player.stats['health'] = respawnhealth
			

func _on_StartTrigger_area_entered(area):
	players = get_tree().get_nodes_in_group('players')
	for player in players:
		player.modify_stats("health",-90)
	$Triggers/StartTrigger/CollisionShape2D.disabled = true
	

func _on_respawntrigger0_area_entered(area):
	area.get_parent().position = currentrespawn.position

func _on_respawntrigger1_area_entered(area):
	area.get_parent().position = currentrespawn.position
	
func _on_fightareatrigger_area_entered(area):
	respawnhealth = 40
	currentrespawn = $respawn2
	
func _on_MobSpawnArea_area_entered(area):
	mobs.append(area.get_parent())

func _on_fightareatrigger2_area_entered(area):
	respawnhealth = 40
	currentrespawn = $respawn3

func _on_dashtrigger_area_entered(area):
	currentrespawn = $respawn1
