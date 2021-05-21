extends 'res://scripts/Weapons/Weapon_base.gd'

var stagger_damage = 10
var in_special = false
var special_damage = 20

func _init():
	self.attack_damage = 15
	attack_anim_names['idle'] = 'idle'
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'
	attack_anim_names['special-attack-fall'] = 'special-attack-fall'
	LightAttack_CD.wait_time = 1
	SpecialAttack_CD.wait_time = 3

func _ready():
	position = Vector2(50, 40)

func _process(delta):
	if in_special:
		if get_parent().is_on_floor():
			$Hurtbox2/CollisionShapeSpecial.disabled = false
			in_special = false
			yield(get_tree().create_timer(0.1), "timeout")
			$Hurtbox2/CollisionShapeSpecial.disabled = true
			can_attack = true
			rpc_unreliable("play_animation", attack_anim_names['idle'])

func attack():
	var player_orientation = get_parent().current_orientation
	get_parent().impulse(300, Vector2(player_orientation, -1), 10, false)
	on_emptyhit_sfx()
	rpc_unreliable("play_animation", attack_anim_names['attack'])

func special_attack():
	rpc_unreliable("play_animation", attack_anim_names['special-attack'])
	can_attack = false
	get_parent().impulse(500, Vector2(0, -1), 10, false)
	yield(get_tree().create_timer(0.5), "timeout")
	can_attack = false
	in_special = true
	get_parent().impulse(700, Vector2(0, 1), 10, false)
	rpc_unreliable("play_animation", attack_anim_names['special-attack-fall'])

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var player_orientation = get_parent().current_orientation
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			on_enemyhit_sfx()
			owner.impulse(300, Vector2(player_orientation, -0.8), 10, false) # This should be first otherwise when monster dies owner is null
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'],
			stagger_damage,
			Vector2(player_orientation, 0), 50)
			

func _on_Hurtbox2_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			print("Special attack")
			on_enemyhit_sfx()
			rpc_unreliable("force_special_attack_damage", owner.name)
			#owner.impulse(300, Vector2(player_orientation, -0.8), 10, false)


sync func force_special_attack_damage(mob_name):
#	I don't know why but _on_Area2D_area_entered executes on both master and peer, but _on_Hurtbox2_area_entered not??
	var owner = get_node("/root/MainScene/Mobs/" + mob_name)
	if owner != null:
		owner.take_damage(special_damage + get_parent().stats['damage_modifier'],
		stagger_damage,
		Vector2(0, -1), 500)


sync func do_update_orientation(orientation):
	if orientation:
		#LOOKING LEFT
		self.scale.x = -2
		if self.position.x > 0:
			self.position.x = -self.position.x
	else:
		#LOOKING RIGHT
		self.scale.x = 2
		if self.position.x < 0:
			self.position.x = -self.position.x
	update_weapon_postion(self.position.x, self.rotation_degrees)

func on_emptyhit_sfx():
	$EmptyHit.play()


func on_enemyhit_sfx():
	$EnemyHit.play()



