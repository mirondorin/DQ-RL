extends Node2D

export var attack_damage = 10
var can_attack = true
var mobs_in_area = []

func _ready():
	pass 

sync func attack():
	pass

sync func special_attack():
	pass

sync func update_orientation(orientation):
	pass

func _on_Area2D_area_entered(area):
	pass
