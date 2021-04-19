extends Node


var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 10567
var username
var latency = 0
var delta_latency = 0
var latency_array = []
var client_clock = 0
var decimal_collector : float = 0


func _ready():
	pass


func _physics_process(delta):
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00


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
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	RequestJoin()
	var timer = Timer.new()
	timer.wait_time = 1.5  # could be 0.5
	timer.connect("timeout", self, "DetermineLatency")


remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency


func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())


remote func ReturnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() -1,  -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
			delta_latency = (total_latency / latency_array.size()) - latency
			latency = total_latency / latency_array.size()
			latency_array.clear()


func RequestJoin():
	print("Connecting to request join")
	rpc_id(1, "JoinRequest", username)
	username = ""  # so that sniffers do not sniff it


remote func ReturnJoinRequest(results):
	print("results received: " + str(results))
	if results == true:
		get_tree().get_root().get_node("SceneHandler").lobby_instance._on_connection_success()
		print("Joined in lobby")


func FetchGameData(requester):
	rpc_id(1, "FetchGameData", requester)


remote func ReturnGameData(s_data, requester):
	instance_from_id(requester).SetData(s_data)




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


func SignalGameStart(level):
	rpc_id(1, "SignalGameStart", level)


remote func ReturnGameStart(s_spawn_positions):
	print("Returning game start")
	get_tree().get_root().get_node("SceneHandler").lobby_instance.hide()
	get_tree().get_root().get_node("SceneHandler").mainscene_instance.start_game(s_spawn_positions)


func SendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)


remote func ReceiveWorldState(s_world_state):
	get_tree().get_root().get_node("SceneHandler").mainscene_instance.update_world_state(s_world_state)


