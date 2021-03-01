extends Node2D

export var attack_damage = 10
var attacking = false


func _ready():
	pass 

func attack():
	$AnimationPlayer.play('attack')
	attacking = true

func update_orientation(parent_obj):
	$AnimatedSprite.flip_h = parent_obj.velocity.x < 0
		
	if parent_obj.velocity.x < 0:
		self.rotation_degrees = -180
		if self.position.x > 0:
			self.position.x = -self.position.x
	elif parent_obj.velocity.x > 0:
		self.rotation_degrees = 0
		if self.position.x < 0:
			self.position.x = -self.position.x

#func _process(delta):
#	pass

#func _physics_process(delta):
#	pass	

func _on_Area2D_body_entered(body):
	if attacking:
		var overlapping_bodies = $AnimatedSprite/Area2D.get_overlapping_bodies()
		for body in overlapping_bodies:
			if 'Mob' in body.name:
				if $AnimationPlayer.current_animation == 'attack':
					body.call("take_damage", attack_damage)


func _on_AnimationPlayer_animation_finished(anim_name):
	if $AnimationPlayer.current_animation == 'attack':
		attacking = false
