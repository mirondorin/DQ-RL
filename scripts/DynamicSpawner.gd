tool
extends "res://scripts/EnemySpawner.gd"

func _get_tool_buttons(): return ["new_area"]

export (Dictionary) var spawn_list = {
	'res://scenes/Mobs/Mob.tscn' : 70,
	'res://scenes/Mobs/MobHomingProjectile.tscn' : 10,
	'res://scenes/Mobs/MobProjectile.tscn' : 30
}

var spawn_list_name : Dictionary = {
	"Mob" : 70,
	"MobHomingProjectile" : 10,
	"MobProjectile" :30,
}

var area_list = []

func new_area():
	var newarea = Area2D.new()
	var collision = CollisionShape2D.new() 
	collision.set_shape(RectangleShape2D.new())
	newarea.add_child(collision)
	self.add_child(newarea)
	newarea.owner = self
	collision.owner = self

func _init():
	self.cleanup = false
	self.start_enabled = true
	self.spawn_continously = true
	self.spawn_delay = 3
	
func _ready():
	randomize()
	for node in get_children():
		if node is Area2D:
			area_list.append(node)
			# print(typeof(node))
	start_spawner()

func get_rand_pos(area):
	var centerpos = area.get_node('CollisionShape2D').position + area.position
	var size = area.get_node('CollisionShape2D').shape.extents
	var position = Vector2(rand_range(-size.x, size.x) + centerpos.x, 
		rand_range(-size.y, size.y) + centerpos.y)
		
	return position

func get_weighted_mob_name():
	var mob_names = spawn_list_name.keys()
	var weights = spawn_list_name.values()
	var max_sum = 0
	for i in weights:
		max_sum += i
	var selected = randi() % max_sum
	var sum = 0
	for i in range(len(weights)):
		sum += weights[i]
		if sum > selected:
			return mob_names[i]
	
	
sync func do_spawn():
#	var enemy = get_weighted_mob()
	var area = area_list[randi() % area_list.size()]

	var position = get_rand_pos(area)
	current_spawns += 1

	mob_type = get_weighted_mob_name()
	get_parent().get_parent().add_new_mob(mob_type, mob_health, position, self)	
#	var inst = load(enemy).instance()
#	inst.spawner = self
#	mainscene.add_child(inst)
#



func _on_Timer_timeout():
	if is_network_master():
		spawn()
	
	if spawn_continously:
		$Timer.start()
	else:
		$Timer.stop()
