extends 'res://scripts/Weapons/Weapon_base.gd'
const bullet = preload("res://scenes/Weapons/WeaponBomb_bullet.tscn")


func _init():
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'
	attack_damage = 1 #just for fun

func _ready():
	position = Vector2(50, 40)

sync func do_attack():
	var bullet_inst = bullet.instance()
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_position = self.global_position
	bullet_inst.attack_damage = self.attack_damage + get_parent().stats['damage_modifier']
	bullet_inst.x_direction = -1 if int($AnimatedSprite.flip_h) else 1
	bullet_inst.impulse(200, Vector2(-1 if int($AnimatedSprite.flip_h) else 1, -2))

func attack():
	do_attack()
	

func special_attack():
#	if is_network_master():
#		rpc_unreliable("play_animation", attack_anim_names['special-attack'])
	pass

func _on_Area2D_area_entered(area):
	pass
