extends Node2D

export var attack_damage = 10
var can_attack = true
var offset_position = Vector2(50, 40)

var attack_anim_names = {
	'attack' : null,
	'special-attack' : null,
}

puppet func do_animation(what, value):
	$AnimatedSprite[what] = value
	pass

master func animate(what, value):
	rpc("do_animation", what, value)
	do_animation(what, value)
	pass
	
puppet func do_play_animation(what):
	$AnimationPlayer.play(what)
	pass

master func play_animation(what):
	rpc("do_play_animation", what)
	do_play_animation(what)
	pass

# Not working!
#remotesync func play_animation(what):
#	$AnimationPlayer.play(what)

func _ready():
	position = offset_position

func attack():
	pass

func special_attack():
	pass

func update_orientation(orientation):	
	animate("flip_h", orientation)
	if orientation:
		self.rotation_degrees = -180
		if self.position.x > 0:
			self.position.x = -self.position.x
	else:
		self.rotation_degrees = 0
		if self.position.x < 0:
			self.position.x = -self.position.x

