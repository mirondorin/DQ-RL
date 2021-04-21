extends 'res://scripts/Weapons/Weapon_base.gd'

const bullet = preload("res://scenes/Weapons/WeaponProjectile_bullet.tscn")

func _init():
	self.attack_damage = 5
	LightAttack_CD.wait_time = 0.6

sync func do_attack():
	on_attack_sfx()
	var bullet_inst = bullet.instance()
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_position = self.global_position
	bullet_inst.attack_damage = self.attack_damage + get_parent().stats['damage_modifier']
	bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1

func attack():
	rpc_unreliable("do_attack")

func on_attack_sfx():
	$ProjectileSfx.play()
