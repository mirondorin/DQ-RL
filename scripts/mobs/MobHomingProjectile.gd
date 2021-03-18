extends "res://scripts/mobs/MobProjectile.gd"

func _ready():
	bullet = load("res://scenes/Weapons/HomingProjectile_bullet.tscn")
	max_dist_player = 200
	pass

sync func do_attack():
	var bullet_inst = bullet.instance()
	bullet_inst.group_to_detect = 'players'
	bullet_inst.to_follow = in_area[0]
	bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_position = self.global_position
	can_attack = false
	attack_timer.start()

#func _process(delta):
#	pass
