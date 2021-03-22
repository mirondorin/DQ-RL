extends "res://scripts/Entity.gd"

export var attack_damage = 10
export var destroy_on_hit = true
export var direction = 1 #1 right, -1 left
export var fuse_time = 1
var group_to_detect = 'mobs'
		
func _ready():
	set_as_toplevel(true)
	change_animation("animation", "bomb_idle")
	yield(get_tree().create_timer(fuse_time), "timeout")
	$Hurtbox/CollisionShape2D.disabled = false
	$AnimatedSprite.scale *= 2
	self.velocity *= 0
	self.GRAVITY = 0
	self.impulse_dir *= 0
	self.x_direction = 0
	change_animation("animation", "explosion")
	yield(get_tree().create_timer(0.24), "timeout")
	self.queue_free()

func _physics_process(delta):
	solve_impulse()
	if is_on_floor():
		velocity.y = 0
		x_direction = 0
		impulse_current_y /= 2
	if is_on_wall():
		x_direction *= -1
		
	velocity.y += delta * GRAVITY
	velocity.x = x_direction * SPEED + impulse_dir.x * impulse_current_x
	var vel_y = velocity.y + impulse_dir.y * impulse_current_y
	var vel = Vector2(velocity.x, vel_y)
	move_and_slide(vel, Vector2(0, -1))
	rotation_degrees += (velocity.x * x_direction)/7

func take_damage(value, direction, impulse_force):
	pass

func on_take_damage(direction, impulse_force):
	pass

func _on_Hurtbox_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group(group_to_detect):
			var dir = (owner.position - self.position).normalized()
			dir.y -= 1
			owner.take_damage(attack_damage, dir, 400)