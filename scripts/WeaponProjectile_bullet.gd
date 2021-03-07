extends KinematicBody2D

export var attack_damage = 10
export var destroy_on_hit = true
export var direction = 1 #1 right, -1 left
export var speed = 200

func _ready():
	set_as_toplevel(true)
	
func _physics_process(delta):
	move_and_slide(Vector2(speed*direction, 0), Vector2(1, 0))
	

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if 'Mob' in owner.name:
			owner.take_damage(attack_damage)
			if destroy_on_hit:
				$".".queue_free()
