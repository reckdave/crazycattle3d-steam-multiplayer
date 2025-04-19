extends Node

const port : int = 8080
const default_ip : String = "127.0.0.1"

var peer
var players : Dictionary = {}
var lobby_id : int = 0

signal updated_player_list
signal failed_to_connect

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

# multiplayer calls
func create_server(server_type,visibility):
	match (server_type):
		0: # STEAM
			peer = SteamMultiplayerPeer.new()
			peer.lobby_created.connect(_on_lobby_created)
			peer.create_lobby(visibility,32)
			
			multiplayer.multiplayer_peer = peer
		1: #LOCAL
			peer = ENetMultiplayerPeer.new()
			var error = peer.create_server(port,50)
			if error:
				peer = null
				return error
			multiplayer.multiplayer_peer = peer
			sendplayerdata(Global.player_data,multiplayer.get_unique_id())
	return true
func join_server(server_type,ip):
	match (server_type):
		0: # STEAM
			peer = SteamMultiplayerPeer.new()
			peer.lobby_joined.connect(_on_lobby_joined)
			peer.connect_lobby(int(ip))
			
			
			multiplayer.multiplayer_peer = peer
		1: # LOCAL
			peer = ENetMultiplayerPeer.new()
			var error = peer.create_client(ip,port)
			if error:
				peer = null
				return error
			multiplayer.multiplayer_peer = peer
	return true

func _client_disconnect():
	multiplayer.multiplayer_peer = null
	MultiplayerHandler.players = {}
	MultiplayerHandler.peer = null

# multiplayer rpcs
@rpc("any_peer","call_remote","reliable")
func sendplayerdata(data,pid):
	if !(players.has(pid)):
		data["pid"] = pid
		players[pid] = data
		#print(players[pid])
		updated_player_list.emit()
	
	if (multiplayer.is_server()):
		for player in players:
			sendplayerdata.rpc(players[player],player)

# multiplayer connects
func _peer_connected(pid):
	pass
func _peer_disconnected(pid):
	players.erase(pid)
	updated_player_list.emit()
func _connected_to_server():
	#print("%s has joined: %s" % [multiplayer.get_unique_id(),multiplayer.get_remote_sender_id()])
	sendplayerdata.rpc_id(1,Global.player_data,multiplayer.get_unique_id())
func _connection_failed():
	failed_to_connect.emit()
# STEAM
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		# Set the lobby ID
		lobby_id = this_lobby_id
		print("Created a lobby: %s" % lobby_id)

		# Set this lobby as joinable, just in case, though this should be done by default
		Steam.setLobbyJoinable(lobby_id, true)

		# Set some lobby data
		Steam.setLobbyData(lobby_id, "name", "%s's CATTLE Lobby" % Global.player_data.username)
		Steam.setLobbyData(lobby_id, "mode", "CATTLE-MULTIPLAYER")
		
		DisplayServer.clipboard_set(str(this_lobby_id))
		OS.alert("THE LOBBY ID IS ON YOUR CLIPBOARD","HEY")
		
		sendplayerdata(Global.player_data,multiplayer.get_unique_id())
		# Allow P2P connections to fallback to being relayed through Steam if needed
		#var set_relay: bool = Steam.allowP2PPacketRelay(true)
		#print("Allowing Steam to be relay backup: %s" % set_relay)
func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	# If joining was successful
	print("joining lobby..")
	if response == 1:
		# Set this lobby ID as your lobby ID
		print("success!")
		lobby_id = this_lobby_id
