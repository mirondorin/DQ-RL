extends Node2D

export var attack_damage = 10
var can_attack = true
const bullet = preload("res://scenes/WeaponProjectile_bullet.tscn")

func _ready():
	position = Vector2(50, 40)

func attack():
	#$AnimationPlayer.play('attack')
	
	var bullet_inst = bullet.instance()
	get_tree().get_root().add_child(bullet_inst)
	bullet_inst.global_position = self.global_position
	bullet_inst.attack_damage = attack_damage + get_parent().stats['damage_modifier']
	bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1

#func special_attack():
#	$AnimationPlayer.play("special-attack")

func update_orientation(orientation):
	
	$AnimatedSprite.flip_h = orientation
		
	if orientation:
		self.rotation_degrees = -180
		if self.position.x > 0:
			self.position.x = -self.position.x
	else:
		self.rotation_degrees = 0
		if self.position.x < 0:
			self.position.x = -self.position.x

#func _process(delta):
#	pass

#func _physics_process(delta):
#	pass	

