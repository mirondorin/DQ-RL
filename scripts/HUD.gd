extends CanvasLayer

onready var healthbar = $AbilitiesBox/CenterContainer/VBoxContainer/Healthbar

func set_ui_key_labels():
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/LAttack.text = char(GlobalSettings.keybinds['attack'])
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/SAttack.text = char(GlobalSettings.keybinds['special_attack'])
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/Utility.text = char(GlobalSettings.keybinds['utility'])
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/Bombs.text = 'Q'


func update_healthbar():
	healthbar.max_value = get_parent().stats["max_health"]
	healthbar.value = get_parent().stats["health"]

func _ready():
	add_to_group("hud")
	set_ui_key_labels()

