extends 'res://scripts/mobs/Mob_base.gd'

const bullet = preload("res://scenes/WeaponProjectile_bullet.tscn")
var max_dist_player = 150


func _init():
	self.SPEED = 20

func follow_player():
	if len(in_area) > 0:
		player = in_area[0]
		if abs(position.x - player.position.x) > max_dist_player:
			if position.x < player.position.x:
				x_direction = 1
			else:
				x_direction = -1
		else:
			x_direction = 0
		
		if position.x < player.position.x:
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
	else:
		x_direction = 0
	if not follow:
		x_direction = 0

func attack_player(player): #player will be null here
	if can_attack:
		var bullet_inst = bullet.instance()
		bullet_inst.group_to_detect = 'players'
		bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1
		get_tree().get_root().add_child(bullet_inst)
		bullet_inst.global_position = self.global_position
		can_attack = false
		attack_timer.start()
	
func _process(delta):
	attack_player(null)
	

	

