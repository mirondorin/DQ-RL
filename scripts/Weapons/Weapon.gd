extends 'res://scripts/Weapons/Weapon_base.gd'

func _init():
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'

func _ready():
	position = Vector2(50, 40)

func attack():
	if is_network_master():
		rpc_unreliable("play_animation", attack_anim_names['attack'])

func special_attack():
	if is_network_master():
		rpc_unreliable("play_animation", attack_anim_names['special-attack'])

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'],
			Vector2(-1 if $AnimatedSprite.flip_h else 1, 0), 50)
