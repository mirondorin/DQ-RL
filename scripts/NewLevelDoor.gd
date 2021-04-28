extends "res://scripts/DoorBase.gd"

sync func do_interact(initiator):
	.do_interact(initiator)
	if voted_list.size() == player_num:	
		if is_network_master():
			gamestate.change_level()


