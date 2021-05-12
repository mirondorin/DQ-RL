extends Node

var player_num = 1
var voted_list = []

func _ready():
	if gamestate.get_player_list().size():
		player_num = gamestate.get_player_list().size()
	$MinVotesLabel.text = String(player_num)

sync func do_interact(initiator):
	if not initiator in voted_list:
		voted_list.append(initiator)
		$VotesLabel.text = String(voted_list.size())
	else:
		voted_list.erase(initiator)
		$VotesLabel.text = String(voted_list.size())

func interact(initiator):
	rpc("do_interact", initiator)


