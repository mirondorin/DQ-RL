extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 10567
var username


func _ready():
	pass


func ConnectToServer(_username = "Guest", _ip = "127.0.0.1"):
	username = _username
	ip = _ip
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")


func _OnConnectionFailed():
	print("Failed to connect")
	print("To enable join button")


func _OnConnectionSucceeded():
	print("Succesfully connected")
	RequestJoin()


func RequestJoin():
	print("Connecting to request join")
	rpc_id(1, "JoinRequest", username)
	username = ""  # so that sniffers do not sniff it


remote func ReturnJoinRequest(results):
	print("results received: " + str(results))
	if results == true:
		get_tree().get_root().get_node("SceneHandler").lobby_instance._on_connection_success()
		print("Joined in lobby")


func FetchGameData(data_name, requester):
	rpc_id(1, "FetchGameData", data_name, requester)


remote func ReturnGameData(data_name, s_data, requester):
	instance_from_id(requester).SetData(data_name, s_data)


func FetchPlayerList(requester):
	print("Fetching player list")
	rpc_id(1, "FetchPlayerList", requester)


remote func ReturnPlayerList(s_players, requester):
	print("Returning player list")
	print(s_players)
	instance_from_id(requester).set_player_list(s_players)


remote func SignalPlayerListRefresh(s_players):
#	TODO: this could be better with an emit("signal")
	print("Being notified of new player connection")
	get_tree().get_root().get_node("SceneHandler").lobby_instance.set_player_list(s_players)


func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")


remote func ReturnPlayerStats(s_stats):
	print("Player stats: " + str(s_stats))


remote func SpawnNewPlayer(player_id, spawn_position):
	get_node("../SceneHandler/MainScene").SpawnNewPlayer(player_id, spawn_position)


remote func DespawnPlayer(player_id):
	get_node("../SceneHandler/MainScene").DespawnPlayer(player_id)
