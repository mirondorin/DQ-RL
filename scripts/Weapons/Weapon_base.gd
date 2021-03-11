extends Node2D

export var attack_damage = 10
var can_attack = true
var offset_position = Vector2(50, 40)

var attack_anim_names = {
	'attack' : null,
	'special-attack' : null,
}

func _ready():
	position = offset_position

func attack():
	pass

func special_attack():
	pass

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

