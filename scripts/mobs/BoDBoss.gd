extends "res://scripts/mobs/Mob_base.gd"

var can_slash_attack = true
var slash_attacking = false
var can_cast_attack = true
var cast_attacking = false
var players_in_sight = 0
	
func _ready():
	stats['default_speed'] = 100
	self.stats['health'] = 500  * (1 + 0.2 *GlobalSettings.level_nr)
	self.stats['max_health'] = 500  * (1 + 0.2 *GlobalSettings.level_nr)
	self.stats['stagger_default'] = 800
	self.stats['stagger_health'] = 800
	self.SPEED = stats['default_speed'] 
	can_jump = false
	$HealthLabel.text = str(self.stats['health'])
	$HealthBar.max_value = self.stats['health']
	$HealthBar.value = self.stats['health']
	$Hurtbox.monitoring = false


func _process(delta):
	if players_in_sight > 0 and can_slash_attack:
		$AnimationPlayer.play("slash_attack")


func flip_sprite():
	if x_direction == -1:
		animation_dict["offset"] = Vector2(70, 0)
		new_animation_dict["offset"] = Vector2(70, 0)
		animation_change = true
		$Hurtbox.scale.x *= -1.0
		$AttackArea.scale.x *= -1.0
	else:
		animation_dict["offset"] = Vector2(0, 0)
		new_animation_dict["offset"] = Vector2(0, 0)
		animation_change = true
		$Hurtbox.scale.x = abs($Hurtbox.scale.x)
		$AttackArea.scale.x = abs($AttackArea.scale.x)


func solve_animation(velocity):
	if x_direction != 0:
		animation_change = true
		if not key_has_value(animation_dict, "flip_h", (x_direction < 0)):
			flip_sprite()
			animation_dict["flip_h"] = (x_direction < 0)
			new_animation_dict["flip_h"] = (x_direction < 0)
			animation_change = true
		if not key_has_value(animation_dict, "animation", "walk"):
			animation_dict["animation"] = 'walk'
			new_animation_dict["animation"] = 'walk'
			animation_change = true
	if velocity.x == 0:	
		if slash_attacking:
			if not key_has_value(animation_dict, "animation", "attack"):
				animation_dict["animation"] = 'attack'
				new_animation_dict["animation"] = 'attack'
				animation_change = true
		else:
			if not key_has_value(animation_dict, "animation", "idle"):
				animation_dict["animation"] = "idle" 
				new_animation_dict["animation"] = "idle" 
				animation_change = true


sync func attack_player(player_name):
	var player = get_node("/root/MainScene/Players/" + player_name)
	player.take_damage(attack_damage, 0, Vector2(x_direction, 0), 10)  # TODO: ensure that player takes damage only once, and takes it everywhere


func slash_attack_toggle():
	slash_attacking = true
	follow = false


sync func slash_attack():
	if can_slash_attack:
		$Hurtbox.set_deferred("monitoring", true)
		can_slash_attack = false
		$SlashAttackCooldown.start()

		
func slash_attack_reset():
	slash_attacking = false
	follow = true
	$Hurtbox.set_deferred("monitoring", false)


func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox'): #  and is_network_master()
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			rpc_unreliable("attack_player", owner.name)


func _on_AnimatedSprite_frame_changed():
	pass


func _on_CastAttackCooldown_timeout():
	can_cast_attack = true


func _on_SlashAttackCooldown_timeout():
	can_slash_attack = true


func _on_AttackArea_body_entered(body):
	if body in in_area:
		if body.is_in_group("players"):
			players_in_sight += 1


func _on_AttackArea_body_exited(body):
	if body.is_in_group("players"):
		players_in_sight -= 1
