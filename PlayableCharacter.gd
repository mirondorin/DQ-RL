extends Area2D

export var speed = 200

func walk(velocity_x):
	if velocity_x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_h = velocity_x < 0

func jump(velocity_y):
	if velocity_y != 0:
		$AnimatedSprite.animation = "jump"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	walk(velocity.x)
	jump(velocity.y)

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
