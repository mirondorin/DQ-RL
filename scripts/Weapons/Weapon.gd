extends 'res://scripts/Weapons/Weapon_base.gd'

var stagger_damage = 5

func _init():
	lighticon = preload("res://.import/weapon_golden_sword.png-2d4627ce6a700a3263fd75d1206180db.stex")
	specialicon = lighticon
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'
	LightAttack_CD.wait_time = 0.4
	SpecialAttack_CD.wait_time = 3

func _ready():
	position = Vector2(50, 40)

func attack():
	on_emptyhit_sfx()
	rpc_unreliable("play_animation", attack_anim_names['attack'])

func special_attack():
	rpc_unreliable("play_animation", attack_anim_names['special-attack'])

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			on_enemyhit_sfx()
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'],
			stagger_damage,
			Vector2(-1 if $AnimatedSprite.flip_h else 1, 0), 50)

func on_emptyhit_sfx():
	$EmptyHit.play()


func on_enemyhit_sfx():
	$EnemyHit.play()
