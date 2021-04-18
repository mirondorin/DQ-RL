extends "res://scripts/mobs/Mob_base.gd"

var bullet
var can_pebble_attack = true
var can_jump_attack = true
var pebble_attacking = false
var jump_attacking = false

func _ready():
	bullet = load("res://scenes/Weapons/GolemPebble.tscn")
	
func _init():
	stats['default_speed'] = 100
	self.stats['health'] = 200
	self.stats['stagger_default'] = 300
	self.stats['stagger_health'] = 300
	self.SPEED = stats['default_speed'] 
	can_jump = false

func _process(delta):
	pebble_attack_init()
	jump_attack_init()
	
	if is_on_floor():
		if jump_attacking:
			jump_attack_reset()
	#print(can_jump_attack)

func solve_animation(velocity):
	if x_direction != 0:
		animation_change = true
		if jump_attacking:
			if not key_has_value(animation_dict, "animation", "idle"):
				animation_dict["animation"] = "idle" 
				new_animation_dict["animation"] = "idle" 
				animation_change = true
		else:
			if not key_has_value(animation_dict, "flip_h", (x_direction < 0)):
				animation_dict["flip_h"] = (x_direction < 0)
				new_animation_dict["flip_h"] = (x_direction < 0)
				animation_change = true
			if not key_has_value(animation_dict, "animation", "walk"):
				animation_dict["animation"] = 'walk'
				new_animation_dict["animation"] = 'walk'
				animation_change = true
	if velocity.x == 0:
		if pebble_attacking:
			if not key_has_value(animation_dict, "animation", "rock_throw"):
				animation_dict["animation"] = "rock_throw" 
				new_animation_dict["animation"] = "rock_throw" 
				animation_change = true
		else:
			if not key_has_value(animation_dict, "animation", "idle"):
				animation_dict["animation"] = "idle" 
				new_animation_dict["animation"] = "idle" 
				animation_change = true
	
func jump_attack_init():
	if can_jump and can_jump_attack and not pebble_attacking and player != null:
		can_jump_attack = false
		can_pebble_attack = false
		can_jump = false
		follow = false
		jump_attacking = true
		jump_attack_exec()
		
func jump_attack_exec():
	var dir_x = 1 if self.position.x < player.position.x else -1
	move_and_slide(Vector2(0, -10))
	impulse(300, Vector2(dir_x, -2), 5, false)
	

func jump_attack_reset():
	if jump_attacking:
		$Hurtbox/CollisionShape2D.disabled = false	
		$AttackCooldown.start()	
		jump_attacking = false
		follow = true
		yield(get_tree().create_timer(0.2), "timeout")
		$Hurtbox/CollisionShape2D.disabled = true	
	
func attack_player(player):
	player.take_damage(attack_damage, 0, Vector2(x_direction, 0), 10)  # TODO: ensure that player takes damage only once, and takes it everywhere
		
sync func pebble_attack_init():
	if can_pebble_attack and not jump_attacking:
		$AnimationPlayer.play("rock_throw")
		follow = false
		pebble_attacking = true
		can_pebble_attack = false

func pebble_attack_exec():
	var hp = float(stats["health"])/stats["max_health"]
	var nr = 1 + 2- (int(hp*2))
	if hp*2 > (int(hp*2)):
		nr-=1
	for i in range(0,nr):
		var bullet_inst = bullet.instance()
		bullet_inst.group_to_detect = 'players'
		get_tree().get_root().add_child(bullet_inst)
		bullet_inst.global_position = self.global_position + Vector2(0, 50)
		$PebbleAttackCooldown.start()

func reset_pebble_attack():
	follow = true
	pebble_attacking = false

func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox'):
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			attack_player(owner)

func _on_AnimatedSprite_frame_changed():
	pass
				

func _on_PebbleAttackCooldown_timeout():
	can_pebble_attack = true

func _on_AttackCooldown_timeout():
	can_jump_attack = true
