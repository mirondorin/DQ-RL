extends 'res://scripts/mobs/Mob_base.gd'

# https://godotengine.org/qa/28113/networking-master-creates-node-instances-and-share-through
# read this mayne helps

func _init():
	stats['default_speed'] = 65
	self.SPEED = stats['default_speed']

# ! normal mob attack is not sync-ed, but seems to work

func attack_player(player):
	if can_attack: 
		player.take_damage(attack_damage, 0, Vector2(x_direction, 0), 10)  # TODO: ensure that player takes damage only once, and takes it everywhere
		impulse(100, Vector2(get_x_orientation() * -1, -1))
		can_attack = false
		follow = false
		attack_timer.start()

func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox'): 
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			attack_player(owner)
