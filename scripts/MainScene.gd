extends Node


onready var mob_root = get_node("Mobs")


var SERVER_PORT = 3001
var MAX_PLAYERS = 2
var SERVER_IP = "127.0.0.1"
var server_peer
var mob = preload("res://scenes/Mobs/Mob.tscn")
var mob_projectile = preload("res://scenes/Mobs/MobProjectile.tscn")
var mob_homing_projectile = preload("res://scenes/Mobs/MobHomingProjectile.tscn")
var golem_boss = preload("res://scenes/Mobs/GolemBoss.tscn")
var mob_id = 0
var all_mobs = []


func _ready():
	pass


func get_new_enemy_instance(type):
	if type == "Mob":
		return mob.instance()
	if type == "MobProjectile":
		return mob_projectile.instance()
	if type == "MobHomingProjectile":
		return mob_homing_projectile.instance()
	if type == "GolemBoss":
		return golem_boss.instance()
	return mob.instance()


func add_new_mob(mob_type, mob_health, position, spawner):
	mob_id += 1
	rpc("do_add_mob", mob_id, mob_type, mob_health, position, spawner)


sync func do_add_mob(mob_id, mob_type, mob_health, position, spawner):
	var lvl_nr = get_node("GlobalSettings").level_nr
	mob_health = int(mob_health * float(lvl_nr + 2) / 2)
	var new_mob = get_new_enemy_instance(mob_type)
	new_mob.get_node("HealthLabel").text = str(mob_health)
	new_mob.stats["health"] = mob_health
	new_mob.position = position
	new_mob.name = str(mob_id)
	new_mob.z_index = 2
	new_mob.spawner = spawner
	get_node("Mobs").add_child(new_mob, true)
	all_mobs.append(mob_id)


sync func do_remove_mob(id):
	if get_node("Mobs").get_node(str(id)) != null:
		all_mobs.erase(id)
		var mob = get_node("Mobs").get_node(str(id))
		get_node("Mobs").remove_child(mob)
		mob.queue_free()


func remove_mob(id):
	rpc("do_remove_mob", id)


func remove_all_mobs():
	for n in get_node("Mobs").get_children():
		remove_mob(n.name)


