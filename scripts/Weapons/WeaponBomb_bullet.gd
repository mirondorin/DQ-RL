extends "res://scripts/Entity.gd"

export var attack_damage = 10
export var destroy_on_hit = true
export var direction = 1 #1 right, -1 left
export var fuse_time = 1
var group_to_detect = 'mobs'
		
func _ready():
	set_as_toplevel(true)
	animation_change = true
	animation_dict["animation"] = "bomb_idle"
	change_animation()
	yield(get_tree().create_timer(fuse_time), "timeout")
	$Hurtbox/CollisionShape2D.disabled = false
	$AnimatedSprite.scale *= 2
	self.velocity *= 0
	self.GRAVITY = 0
	self.impulse_dir *= 0
	self.x_direction = 0
	animation_change = true
	animation_dict["animation"] = "explosion"
	change_animation()
	on_explosion_sfx()
	yield(get_tree().create_timer(0.24), "timeout") #TODO change timer back to original value?
	self.queue_free()


func change_animation():
	animation_change = false
	do_change_animation(animation_dict)
	animation_dict = {}


func _physics_process(delta):
#	make_animation_calls()
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


func take_damage(value, stagger, direction, impulse_force):
	pass


func on_take_damage(direction, impulse_force):
	pass


func _on_Hurtbox_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group(group_to_detect):
			var dir = (owner.position - self.position).normalized()
			dir.y -= 1
			owner.take_damage(attack_damage, 15, dir, 400)


func on_explosion_sfx():
	var target = get_tree().get_root().get_node("MainScene/GlobalSounds")
	var source = $ExplosionSfx
	self.remove_child(source)
	target.add_child(source)
	source.play()
