extends Control


onready var connection_panel = get_node("Connect")
onready var players_panel = get_node("Players")
onready var username_input = get_node("Connect/Name")
onready var server_ip = get_node("Connect/IPAddress")
onready var error_label = get_node("Connect/ErrorLabel")
onready var join_button = get_node("Connect/Join")
onready var player_list = get_node("Players/List")

var players = []


func _ready():
	if OS.has_environment("USERNAME"):
		username_input.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		username_input.text = desktop_path[desktop_path.size() - 2]


func _on_join_pressed():
	if username_input.text == "":
		error_label.text = "Invalid name!"
		return
	var ip = server_ip.text
	if not ip.is_valid_ip_address():
		error_label.text = "Invalid IP address!"
		return
	error_label.text = ""
	join_button.disabled = true
	var username = username_input.get_text()
	print("Attempting to join")
	Server.ConnectToServer(username)


func _on_connection_success():
	connection_panel.hide()
	players_panel.show()
	refresh_player_list()


func refresh_player_list():
	Server.FetchPlayerList(get_instance_id())


func _on_connection_failed():
	join_button.disabled = false
	error_label.set_text("Connection failed.")


func _on_game_ended():
	show()
	connection_panel.show()
	players_panel.hide()
	join_button.disabled = false


func _on_game_error(errtxt):
	error_label.dialog_text = errtxt
	error_label.popup_centered_minsize()
	join_button.disabled = false


func refresh_lobby():
	players.sort()
	player_list.clear()
	for p in players:
		player_list.add_item(p)


func set_player_list(s_players):
	players = s_players
	refresh_lobby()
