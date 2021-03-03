extends Node2D

export var attack_damage = 10
var can_attack = true
var mobs_in_area = []

func _ready():
	pass 

func attack():
	$AnimationPlayer.play('attack')
	#if can_attack:
		#for mob in mobs_in_area:
		#	if mob!=null:
		#		mob.call("take_damage", attack_damage)
	#	can_attack=false

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

#func _process(delta):
#	pass

#func _physics_process(delta):
#	pass	

func _on_Area2D_body_entered(body):
	var overlapping_bodies = $Area2D.get_overlapping_bodies()
	for body in overlapping_bodies:
		if 'Mob' in body.name:
			mobs_in_area.append(body)
			body.call("take_damage", attack_damage)

func _on_AnimationPlayer_animation_finished(anim_name):
	pass


func _on_Area2D_body_exited(body):
	var overlapping_bodies = $Area2D.get_overlapping_bodies()
	for body in overlapping_bodies:
		if 'Mob' in body.name:
			var mob_ind = mobs_in_area.find(body)
			mobs_in_area.remove(mob_ind)
			
	pass # Replace with function body.
