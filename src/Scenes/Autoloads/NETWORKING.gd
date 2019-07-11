extends Node

const MAX_PLAYERS : int = 2

var current_players : Dictionary = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func become_host(port : int):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(peer)

func join_host(ip_address : String, port : int):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_address, port)
	get_tree().set_network_peer(peer)

func disconnet():
	get_tree().set_network_peer(null)

func add_player_to_match(new_player : MatchedPlayer):
	current_players[new_player.connection_id] = new_player
func remove_player_from_match(player_id : int):
	current_players.erase(player_id)

func _peer_connected(new_peer_id : int):
	pass
func _peer_disconnected(new_peer_id : int):
	remove_player_from_match(new_peer_id)

func _connected_ok():
	pass
func _connected_fail():
	pass
func _server_disconnected():
	pass