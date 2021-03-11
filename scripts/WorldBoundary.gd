extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var collider_shape = get_node("Area2D/CollisionShape2D").shape
var level_lenght = 10000  # hardcodat, ar trebuii luat de undeva
var level_depth = 550  # hardcoded for this scene, to be changed to scene depth

# Called when the node enters the scene tree for the first time.
func _ready():
	position.y = level_depth
	collider_shape.extents = Vector2(level_lenght, 10)

func _on_Area2D_body_entered(body):
	if (body.has_method("out_of_bounds")):
		body.out_of_bounds()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
