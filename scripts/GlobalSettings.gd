extends Node

export var GRAVITY = 500.0
var level_nr = 0
signal changed_binds

var player_sprite_type = {}

onready var settingsmenu = load("res://scenes/Menu.tscn")
onready var menu = settingsmenu.instance()
var filepath = "res://keybinds.ini"
var configfile
var keybinds = {}

func _input(event):
	if Input.is_action_just_pressed("ui_home") and menu != null:
		if menu.is_opened:
			menu.get_node("Panel").visible = false
			menu.is_opened = false
		else:
			menu.get_node("Panel").visible = true
			menu.is_opened = true


func _ready():
	configfile = ConfigFile.new()
	if configfile.load(filepath) == OK:
		for key in configfile.get_section_keys("keybinds"):
			var key_value = configfile.get_value("keybinds", key)
			
			if str(key_value) != "":
				keybinds[key] = key_value
			else:
				keybinds[key] = null
	else:
		print("CONFIG FILE NOT FOUND") # Config should be created somehow
	add_child(menu)
	set_game_binds()


func set_game_binds():
	for key in keybinds.keys():
		var value = keybinds[key]
		
		var actionlist = InputMap.get_action_list(key)
		if !actionlist.empty():
			InputMap.action_erase_event(key, actionlist[0])
		
		if value != null:
			var new_key = InputEventKey.new()
			new_key.set_scancode(value)
			InputMap.action_add_event(key, new_key)


func write_config():
	get_tree().call_group("hud", "set_ui_key_labels")
	for key in keybinds.keys():
		var key_value = keybinds[key]
		if key_value != null:
			configfile.set_value("keybinds", key, key_value)
		else:
			configfile.set_value("keybinds", key, "")
	configfile.save(filepath)

