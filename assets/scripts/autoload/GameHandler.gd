extends Node

@onready var ireland: PackedScene = preload("res://assets/scenes/testscene.tscn")
@onready var cattle: PackedScene = preload("res://assets/objects/player.tscn")

var world: Node
var alive_players: Array[int]
var on_going: bool = false

func _ready() -> void :
    SignalBus.player_died.connect(on_player_death)
    SignalBus.player_left.connect(on_player_left)

func on_player_death(pid: int) -> void :
    alive_players.erase(pid)

    if not multiplayer.is_server(): return
    if alive_players.size() <= 1: end_game.rpc(alive_players[0])

func on_player_left(pid: int) -> void :
    if on_going:
        var player: Player = world.get_node("Game").get_node(str(pid))
        player.controller.get_node("usernameLabel").hide()
        player.force_kill.rpc()

    if pid == 1:
        OS.alert("THE HOST HAS LEFT.")
        get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")


@rpc("authority", "call_local", "reliable")
func end_game(win_pid: int) -> void :
    if multiplayer.get_remote_sender_id() != 1: return
    if not on_going: return
    on_going = false

    if win_pid == Global.player.pid:
        Data.data.game.wins += 1
    else:
        Data.data.game.loses += 1
        if Data.data.game.loses >= 10:
            Data.give_achievement("Absolute Loser")
    Data.save()

    await get_tree().create_timer(5).timeout

    if not world: return

    for child in world.get_node("Game").get_children():
        child.queue_free()
    alive_players.clear()

    world.get_node("UI").show()


@rpc("authority", "call_local", "reliable")
func start_game(game_data: Dictionary = {}):
    if multiplayer.get_remote_sender_id() != 1: return
    alive_players.clear()
    on_going = true

    var map: Node3D = ireland.instantiate()
    world.get_node("Game").add_child(map)
    world.get_node("UI").hide()
    for pid: int in MultiplayerHandler.players:
        alive_players.append(pid)

        var pdata: Dictionary = MultiplayerHandler.players[pid]
        var player: Player = cattle.instantiate()
        player.pid = pid
        player.steamID = pdata.steamID
        player.username = pdata.username
        player.cosmetics = Array(pdata.cosmetics)

        world.get_node("Game").add_child(player)
