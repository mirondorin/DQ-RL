extends "res://scripts/mobs/Mob_base.gd"

var can_slash_attack = true
var slash_attacking = false
var can_cast_attack = true
var cast_attacking = false

	
func _ready():
	stats['default_speed'] = 100
	self.stats['health'] = 800
	self.stats['max_health'] = 800
	self.stats['stagger_default'] = 800
	self.stats['stagger_health'] = 800
	self.SPEED = stats['default_speed'] 
	can_jump = false
	$HealthLabel.text = str(self.stats['health'])
	$HealthBar.max_value = self.stats['health']
	$HealthBar.value = self.stats['health']


func _process(delta):
	pass


func flip_sprite():
	if x_direction == -1:
		$AnimatedSprite.offset = Vector2(70, 0)
		$Hurtbox.scale.x *= -1.0
		$AttackArea.scale.x *= -1.0
	else:
		$AnimatedSprite.offset = Vector2(0, 0)
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



func attack_player(player):
	player.take_damage(attack_damage, 0, Vector2(x_direction, 0), 10)  # TODO: ensure that player takes damage only once, and takes it everywhere


func slash_attack():
	if can_slash_attack:
		follow = false
		slash_attacking = true
		$AnimationPlayer.play("slash_attack")
		$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
		can_slash_attack = false
		$SlashAttackCooldown.start()
		
func slash_attack_reset():
	follow = true
	slash_attacking = false
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)


func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox'): #  and is_network_master()
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			attack_player(owner)


func _on_AnimatedSprite_frame_changed():
	pass


func _on_CastAttackCooldown_timeout():
	can_cast_attack = true


func _on_SlashAttackCooldown_timeout():
	can_slash_attack = true


func _on_AttackArea_body_entered(body):
	if body in in_area:
		if body.is_in_group("players"):
			slash_attack()
