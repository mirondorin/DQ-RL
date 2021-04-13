extends Node2D

export var attack_damage = 10
var can_attack = true
var offset_position = Vector2(50, 40)

var attack_anim_names = {
	'attack' : null,
	'special-attack' : null,
}

var LightAttack_CD
var SpecialAttack_CD

func _init():
	LightAttack_CD = Timer.new()
	LightAttack_CD.connect("timeout",self,"_on_LightAttack_CD_timeout") 
	add_child(LightAttack_CD)
	SpecialAttack_CD = Timer.new()
	SpecialAttack_CD.connect("timeout",self,"_on_SpecialAttack_CD_timeout") 
	add_child(SpecialAttack_CD)

func _on_LightAttack_CD_timeout():
	can_attack = true
	pass

func _on_SpecialAttack_CD_timeout():
	can_attack = true
	pass

sync func change_animation(what, value):
	$AnimatedSprite[what] = value

sync func play_animation(what):
	$AnimationPlayer.play(what)
	
func attack():
	pass

func special_attack():
	pass
	
sync func update_weapon_postion(x, radians):
	self.position.x = x
	self.rotation_degrees = radians
	
sync func do_update_orientation(orientation):
	if orientation:
		self.rotation_degrees = -180
		if self.position.x > 0:
			self.position.x = -self.position.x
	else:
		self.rotation_degrees = 0
		if self.position.x < 0:
			self.position.x = -self.position.x
	change_animation("flip_h", orientation)
	update_weapon_postion(self.position.x, self.rotation_degrees)

func update_orientation(orientation):
	rpc_unreliable("do_update_orientation", orientation)

