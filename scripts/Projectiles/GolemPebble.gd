extends "res://scripts/Entity.gd"

var group_to_detect
var direction
var attack_damage = 15

func _ready():
	set_as_toplevel(true)
	group_to_detect = 'players'
	var force = rand_range(400, 600)
	direction = Vector2(1, 0).rotated(rand_range(0, PI) + PI)
	impulse(force, direction)
	pass

#func _process(delta):
#	pass

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group(group_to_detect):
			owner.take_damage(attack_damage, 50, direction, 0)
		queue_free()

func _physics_process(delta):
	solve_impulse()
	if is_on_floor():
		queue_free()
	if is_on_wall():
		x_direction *= -1
		impulse_dir.x *= -1
		
	velocity.y += delta * GRAVITY
	velocity.x = x_direction * SPEED + impulse_dir.x * impulse_current_x
	var vel_y = velocity.y + impulse_dir.y * impulse_current_y
	var vel = Vector2(velocity.x, vel_y)
	move_and_slide(vel, Vector2(0, -1))
	rotation_degrees += (velocity.x * x_direction)/7
