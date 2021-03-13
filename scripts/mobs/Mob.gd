extends 'res://scripts/mobs/Mob_base.gd'

# https://godotengine.org/qa/28113/networking-master-creates-node-instances-and-share-through
# read this mayne helps

func _init():
	self.SPEED = 70

func attack_player(player):
	if can_attack and is_network_master():
		player.take_damage(attack_damage)  # TODO: ensure that player takes damage only once, and takes it everywhere
		move_and_slide(Vector2(velocity.x + 2000*x_direction*-1, velocity.y), Vector2(0, -1))
		can_attack = false
		attack_timer.start()

func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox') and is_network_master():
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			attack_player(owner)
