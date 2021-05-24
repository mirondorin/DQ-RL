extends CanvasLayer

onready var healthbar = $AbilitiesBox/CenterContainer/VBoxContainer/VideoPlayer/Healthbar
onready var healthtext = $AbilitiesBox/CenterContainer/VBoxContainer/VideoPlayer/HealthText

onready var lightprogress = $AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer/CenterContainer/LightProgress
onready var specialprogress = $AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer/CenterContainer2/SpecialProgress
onready var utilityprogress = $AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer/CenterContainer3/UtilityProgress
onready var bombprogress = $AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer/CenterContainer4/BombProgress

onready var lighticon = $AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer/CenterContainer/lighticon
onready var specialicon = $AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer/CenterContainer2/specialicon

func set_ui_key_labels():
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/LAttack.text = char(GlobalSettings.keybinds['attack'])
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/SAttack.text = char(GlobalSettings.keybinds['special_attack'])
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/Utility.text = char(GlobalSettings.keybinds['utility'])
	$AbilitiesBox/CenterContainer/VBoxContainer/HBoxContainer2/Bombs.text = 'Q'

func update_healthbar():
	healthbar.max_value = get_parent().stats["max_health"]
	healthbar.value = get_parent().stats["health"]
	healthtext.text = String(get_parent().stats["health"]) + "/" + String(get_parent().stats["max_health"])

func update_icons():
	lighticon.texture = get_parent().current_weapon.lighticon
	specialicon.texture = get_parent().current_weapon.specialicon

func _ready():
	add_to_group("hud")
	set_ui_key_labels()

func _process(delta):
	lightprogress.value = int(get_parent().current_weapon.LightAttack_CD.time_left / get_parent().current_weapon.LightAttack_CD.wait_time * 100)
	specialprogress.value = int(get_parent().current_weapon.SpecialAttack_CD.time_left / get_parent().current_weapon.SpecialAttack_CD.wait_time * 100)
	utilityprogress.value = int(get_parent().get_node("Cooldown_Root/Utility_CD").time_left / get_parent().get_node("Cooldown_Root/Utility_CD").wait_time * 100)
	bombprogress.value = int(get_parent().weapon_bomb.LightAttack_CD.time_left / get_parent().weapon_bomb.LightAttack_CD.wait_time * 100)
