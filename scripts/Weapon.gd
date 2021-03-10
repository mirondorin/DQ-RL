extends Node2D

export var attack_damage = 10
var can_attack = true
var mobs_in_area = []

func _ready():
	pass 

sync func attack():
	$AnimationPlayer.play('attack')
	#if can_attack:
		#for mob in mobs_in_area:
		#	if mob!=null:
		#		mob.call("take_damage", attack_damage)
	#	can_attack=false

sync func special_attack():
	$AnimationPlayer.play("special-attack")

sync func update_orientation(orientation):
	
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

func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if 'Mob' in owner.name:
			owner.take_damage(attack_damage)
