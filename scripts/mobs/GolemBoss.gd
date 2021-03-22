extends "res://scripts/mobs/Mob_base.gd"

var bullet

func _ready():
	bullet = load("res://scenes/Weapons/GolemPebble.tscn")

func _init():
	self.SPEED = 100
	self.stats['health'] = 100

func attack_player(player):
	if can_attack: # and is_network_master():
		# if is_network_master, player does not take damage because is not on master
		player.take_damage(attack_damage, Vector2(x_direction, 0), 10)  # TODO: ensure that player takes damage only once, and takes it everywhere
		can_attack = false
		follow = false
		attack_timer.start()

sync func pebble_attack():
	var bullet_inst = bullet.instance()
	bullet_inst.group_to_detect = 'players'
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_position = self.global_position

func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox'): #  and is_network_master()
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			attack_player(owner)

func _on_AnimatedSprite_frame_changed():
	pebble_attack()
