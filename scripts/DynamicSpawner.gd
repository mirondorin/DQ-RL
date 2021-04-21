tool
extends "res://scripts/EnemySpawner.gd"

func _get_tool_buttons(): return ["new_area"]

export(Dictionary) var spawn_list = {
	'res://scenes/Mobs/Mob.tscn' : 70,
	'res://scenes/Mobs/MobHomingProjectile.tscn' : 10,
	'res://scenes/Mobs/MobProjectile.tscn' : 30
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
	for node in get_children():
		if node is Area2D:
			area_list.append(node)
			print(typeof(node))
	start_spawner()

func get_rand_pos(area):
	var centerpos = area.get_node('CollisionShape2D').position + area.position
	var size = area.get_node('CollisionShape2D').shape.extents
	var position = Vector2(rand_range(-size.x, size.x) + centerpos.x, 
		rand_range(-size.y, size.y) + centerpos.y)
		
	return position

func get_weighted_mob():
	var selected = []
	for mob in spawn_list:
		for i in range(spawn_list[mob]):
			selected.append(mob)
	randomize()
	return selected[randi() % 100 + 1]
	
sync func do_spawn():
	var enemy = get_weighted_mob()	
	var inst = load(enemy).instance()
	inst.spawner = self
	mainscene.add_child(inst)
	
	var area = area_list[randi() % area_list.size()]
	
	inst.position = get_rand_pos(area)
	inst.velocity.x = 0
	inst.velocity.y = 0
	current_spawns += 1


func _on_Timer_timeout():
	if is_network_master():
		spawn()
	
	if spawn_continously:
		$Timer.start()
	else:
		$Timer.stop()
