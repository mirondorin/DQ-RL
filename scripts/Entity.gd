extends "res://scripts/PhysicsEntity.gd"


var stats = {
	"health" : 0,
	"mana" : 100,
	"stagger_default" : 10,
	"stagger_health" : 10,
	"invincible" : false,
	"default_speed": 100
}

func take_damage(value, stagger, direction, impulse_force):
	if not stats['invincible']:
		do_take_damage(value, stagger, direction, impulse_force)


func do_take_damage(value, stagger, direction, impulse_force):
	stats['health'] -= value
	stats['stagger_health'] -= stagger
	on_take_damage(direction, impulse_force)
	
func on_take_damage(direction, impulse_force):
	if stats['stagger_health'] <= 0:
		animation_dict["animation"] = "hit"
		stats['stagger_health'] = stats['stagger_default']
	$Health.text = String(stats['health'])
	animation_play = ""
	if stats['health'] <= 0:
		$Health.text = 'dead!'
		$Health.add_color_override("font_color", Color(255, 0, 0))
	pass

func do_set_health(value):
	stats['health'] = value
	stats['max_health'] = value
	$HealthLabel.text = String(stats["health"])

func set_initial_health(value):
	do_set_health(value)
