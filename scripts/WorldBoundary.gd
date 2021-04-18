extends Node2D



onready var collider_shape = get_node("Area2D/CollisionShape2D").shape
var level_lenght = 10000 
var level_depth = 550 


func _ready():
	position.y = level_depth
	collider_shape.extents = Vector2(level_lenght, 10)


func _on_Area2D_body_entered(body):
	if (body.has_method("out_of_bounds")):
		body.out_of_bounds()
