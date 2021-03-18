extends 'res://scripts/Weapons/Weapon_base.gd'

const bullet = preload("res://scenes/WeaponProjectile_bullet.tscn")

func _init():
	self.attack_damage = 5

func attack():
	var bullet_inst = bullet.instance()
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_position = self.global_position
	bullet_inst.attack_damage = self.attack_damage + get_parent().stats['damage_modifier']
	bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1


