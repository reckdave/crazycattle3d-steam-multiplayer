extends Node

@onready var sheep_scene : PackedScene = preload("res://assets/objects/player.tscn")
var alive_players : Array = []
var world_node : Node3D

signal game_started
signal game_end
signal player_removed

var ongoing_game : bool = false

var game_data = {
	"MAP": 0
}

func _ready() -> void:
	player_removed.connect(_on_player_removed)
	game_end.connect(_on_game_ended)
	randomize()

func get_player(pid):
	if (ongoing_game):
		return world_node.get_node(str(pid))

@rpc("authority","call_local","reliable")
func start_game(world : PackedScene = load("res://assets/scenes/ireland.tscn")):
	if (multiplayer.get_remote_sender_id() != 1): return
	if (MultiplayerHandler.players.size() <= 1): OS.alert("NOT ENOUGH PLAYERS..","HEY"); return
	
	Steam.setLobbyJoinable(MultiplayerHandler.lobby_id,false)
	multiplayer.multiplayer_peer.refuse_new_connections = true
	
	world_node = world.instantiate()
	get_tree().root.add_child(world_node)
	
	ongoing_game = true
	
	for player in MultiplayerHandler.players:
		var new_player = sheep_scene.instantiate()
		new_player.name = str(player)
		new_player.username = str(MultiplayerHandler.players[player]["username"])
		alive_players.append(player)
		world_node.add_child(new_player)
	game_started.emit()

@rpc("authority","call_local","reliable")
func end_game():
	if !(ongoing_game): return
	ongoing_game = false
	if world_node == null: return
	
	world_node.queue_free()
	alive_players.clear()
	
	Steam.setLobbyJoinable(MultiplayerHandler.lobby_id,true)
	multiplayer.multiplayer_peer.refuse_new_connections = false
	
	game_end.emit()

func _on_game_ended():
	if world_node != null:
		world_node.queue_free()
		alive_players.clear()

func _on_player_removed(_pid  : int):
	if !(multiplayer.is_server()): return
	if alive_players.size() <= 1:
		await get_tree().create_timer(4).timeout
		end_game.rpc()
