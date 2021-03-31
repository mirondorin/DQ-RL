extends "res://scripts/Weapons/WeaponProjectile_bullet.gd"

var to_follow
var rate_of_change = 2


func _ready():
	lifespan = 5
	speed = 100
	direction = 0
	pass

func change_direction(target_position,delta):
	var orientation = self.get_angle_to(target_position)
	if (target_position - self.position).length() < 50:
		self.rotate(orientation * delta *rate_of_change * 5)
	else:
		self.rotate(orientation * delta *rate_of_change)

func look_at_player():
	if -90<self.rotation_degrees and self.rotation_degrees<90:
		$Sprite.flip_v = false
		$Sprite.flip_h = true
	else:
		$Sprite.flip_v = true
		$Sprite.flip_h = true
		
func _physics_process(delta):
	change_direction(to_follow.position,delta)
	
	var direction_vector = Vector2(1,0).rotated(self.rotation)
	move_and_slide(speed*direction_vector, Vector2(1, 0))
	
	look_at_player()
	
	pass
