extends 'res://scripts/Weapons/Weapon_base.gd'

var stagger_damage = 10

func _init():
	self.attack_damage = 1
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'
	LightAttack_CD.wait_time = 1

func _ready():
	position = Vector2(50, 40)

func attack():
	if is_network_master():
		var player_orientation = get_parent().current_orientation
		get_parent().impulse(300, Vector2(player_orientation, -1), 10, false)
		on_emptyhit_sfx()
		rpc_unreliable("play_animation", attack_anim_names['attack'])

func special_attack():
	if is_network_master():
		rpc_unreliable("play_animation", attack_anim_names['special-attack'])

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var player_orientation = get_parent().current_orientation
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			on_enemyhit_sfx()
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'],
			stagger_damage,
			Vector2(player_orientation, 0), 50)
			owner.impulse(300, Vector2(player_orientation, -0.8), 10, false)

sync func do_update_orientation(orientation):
	if orientation:
		#LOOKING LEFT
		self.rotation_degrees = -220
		if self.position.x > 0:
			self.position.x = -self.position.x
	else:
		#LOOKING RIGHT
		self.rotation_degrees = 0
		if self.position.x < 0:
			self.position.x = -self.position.x
	update_weapon_postion(self.position.x, self.rotation_degrees)

func on_emptyhit_sfx():
	$EmptyHit.play()


func on_enemyhit_sfx():
	$EnemyHit.play()
