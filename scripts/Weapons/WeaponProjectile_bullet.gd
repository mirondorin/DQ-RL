extends KinematicBody2D

export var attack_damage = 10
export var destroy_on_hit = true
export var direction = 1 #1 right, -1 left
export var speed = 200
var group_to_detect = 'mobs'
	
func _physics_process(_delta):
	move_and_slide(Vector2(speed*direction, 0), Vector2(1, 0))
	
func _ready():
	set_as_toplevel(true)

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group(group_to_detect):
			owner.take_damage(attack_damage, Vector2(direction, 0))
			if destroy_on_hit:
				$".".queue_free()
