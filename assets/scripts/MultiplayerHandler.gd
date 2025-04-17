extends Node

const port = 8080
const default_ip = "127.0.0.1"

@onready var sheepScene = preload("res://assets/objects/player.tscn")
var player_spawn : Node3D

var lobby_id : int = 0
var lobby_members = []

func create_server(server_type):
	match (server_type):
		0: # STEAM
			var peer = SteamMultiplayerPeer.new()
			peer.lobby_created.connect(_steam_lobby_created)
			peer.peer_connected.connect(_peer_connected)
			
			peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_INVISIBLE)
			multiplayer.multiplayer_peer = peer
		1: #LOCAL
			var peer = ENetMultiplayerPeer.new()
			multiplayer.peer_connected.connect(_peer_connected)
			multiplayer.peer_disconnected.connect(_peer_disconnected)
			
			peer.create_server(port,50)
			multiplayer.multiplayer_peer = peer
			
			add_sheep(multiplayer.get_unique_id())

func join_server(server_type,server_ip):
	match (server_type):
		0: # STEAM
			var peer = SteamMultiplayerPeer.new()
			peer.connect_lobby(int(server_ip))
			multiplayer.multiplayer_peer = peer
			add_sheep(multiplayer.get_unique_id())
			lobby_id = int(server_ip)
		1: #LOCAL
			var peer = ENetMultiplayerPeer.new()
			peer.create_client(default_ip,port)
			multiplayer.multiplayer_peer = peer

func add_sheep(pid):
	var cloneSheep = sheepScene.instantiate()
	cloneSheep.name = str(pid)
	player_spawn.add_child(cloneSheep)
	
# multiplayer connects
func _peer_connected(id : int):
	add_sheep(id)
	print("@mew player")
func _peer_disconnected(id : int):
	# TODO
	pass
# steam connects
func _steam_lobby_created(connect : int, new_lobbyid):
	if connect == 1:
		Steam.setLobbyData(new_lobbyid,"name","%s Lobby" % Steam.getPersonaName())
		Steam.setLobbyJoinable(new_lobbyid,true)
		DisplayServer.clipboard_set(str(new_lobbyid))
		lobby_id = new_lobbyid
		add_sheep(multiplayer.get_unique_id())
	else:
		print("something went wrong")
