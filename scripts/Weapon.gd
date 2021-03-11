extends Node2D

export var attack_damage = 10
var can_attack = true

func _ready():
	position = Vector2(50, 40)

func attack():
	$AnimationPlayer.play('attack')

func special_attack():
	$AnimationPlayer.play("special-attack")

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

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'])
