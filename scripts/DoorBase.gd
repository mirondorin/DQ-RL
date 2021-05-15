extends Node

var player_num = 1
var voted_list = []

func _ready():
	if get_node("/root/MainScene/Players").get_children().size():
		player_num = get_node("/root/MainScene/Players").get_children().size()
#		chestia asta cand se executa nici nu exista playeri in nodu de playeri
	$MinVotesLabel.text = String(player_num)

func reinit():
#	asta ar trebuii apelata cand se incarca playerii
	if get_node("/root/MainScene/Players").get_children().size():
		player_num = get_node("/root/MainScene/Players").get_children().size()
	$MinVotesLabel.text = String(player_num)

sync func do_interact(initiator):
	reinit()
	if not initiator in voted_list:
		voted_list.append(initiator)
		$VotesLabel.text = String(voted_list.size())
	else:
		voted_list.erase(initiator)
		$VotesLabel.text = String(voted_list.size())

func interact(initiator):
#	get_tree().get_network_unique_id() better than initiator which is object and not the same on the 2 clients
	rpc("do_interact", get_tree().get_network_unique_id())


