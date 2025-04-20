extends Node

@onready var sheep_scene : PackedScene = preload("res://assets/objects/player.tscn")
var alive_players : Array = []
var world_node : Node3D

signal game_started
signal game_end

func _ready() -> void:
	randomize()

@rpc("authority","call_local","reliable")
func start_game(world : PackedScene = load("res://assets/scenes/ireland.tscn")):
	if (multiplayer.get_remote_sender_id() != 1): return
	if (MultiplayerHandler.players.size() <= 1): OS.alert("NOT ENOUGH PLAYERS..","HEY"); return
	
	Steam.setLobbyJoinable(MultiplayerHandler.lobby_id,false)
	multiplayer.multiplayer_peer.refuse_new_connections = true
	
	world_node = world.instantiate()
	get_tree().root.add_child(world_node)
	
	for player in MultiplayerHandler.players:
		var new_player = sheep_scene.instantiate()
		new_player.name = str(player)
		new_player.username = str(MultiplayerHandler.players[player]["username"])
		alive_players.append(player)
		world_node.add_child(new_player)
	game_started.emit()

@rpc("authority","call_local","reliable")
func end_game():
	await get_tree().create_timer(4).timeout
	if world_node == null: return
	
	world_node.queue_free()
	alive_players.clear()
	
	Steam.setLobbyJoinable(MultiplayerHandler.lobby_id,true)
	multiplayer.multiplayer_peer.refuse_new_connections = false
	
	game_end.emit()
