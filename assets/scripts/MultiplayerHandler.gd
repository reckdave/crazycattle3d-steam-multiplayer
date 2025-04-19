extends Node

const port : int = 8080
const default_ip : String = "127.0.0.1"

var players : Dictionary = {}
var lobby_id : int = 0

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

# multiplayer connects
func _peer_connected():
	pass
func _peer_disconnected():
	pass
func _connected_to_server():
	pass
func _connection_failed():
	pass
