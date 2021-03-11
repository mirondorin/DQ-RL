extends 'res://scripts/weapons/Weapon_base.gd'

func _init():
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'

func _ready():
	position = Vector2(50, 40)

func attack():
	$AnimationPlayer.play(attack_anim_names['attack'])

func special_attack():
	$AnimationPlayer.play(attack_anim_names['special-attack'])

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'])
