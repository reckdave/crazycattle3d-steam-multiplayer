extends Node

const DEFAULT_PORT = 8008
const DEFAULT_IP = "127.0.0.1"
var peer

var players: Dictionary[int, Dictionary] = {}
var lobby_id: int = 0

func _ready() -> void :
    Steam.lobby_created.connect(on_steam_lobby_created)
    Steam.lobby_joined.connect(on_steam_lobby_joined)

    multiplayer.connected_to_server.connect(on_connected_to_server)
    multiplayer.peer_disconnected.connect(on_peer_left)



func create_server(server_type: Enums.server_type) -> void :
    players.clear()
    match server_type:
        Enums.server_type.enet:
            peer = ENetMultiplayerPeer.new()
            peer.create_server(DEFAULT_PORT)

            multiplayer.multiplayer_peer = peer
            setup_player(Global.pdata, 1, Steam.getSteamID())
        Enums.server_type.steam:
            Steam.createLobby(Steam.LobbyType.LOBBY_TYPE_PUBLIC, 16)

func join_server(server_type: Enums.server_type, address: String) -> void :
    players.clear()
    match server_type:
        Enums.server_type.enet:
            peer = ENetMultiplayerPeer.new()
            peer.create_client(DEFAULT_IP, DEFAULT_PORT)

            multiplayer.multiplayer_peer = peer
        Enums.server_type.steam:
            Steam.joinLobby(int(address))

@rpc("any_peer", "call_remote", "reliable")
func setup_player(pdata: Dictionary, pid: int, psteamID: int) -> void :
    if not players.has(pid):
        pdata.pid = pid
        pdata.steamID = psteamID
        players[pid] = pdata
        SignalBus.player_joined.emit(pid)
        print("%s has been setup" % pid)

    if multiplayer.is_server():
        for plr in players:
            setup_player.rpc(players[plr], plr, players[plr].steamID)
    print(players)

func on_connected_to_server() -> void :
    setup_player.rpc_id(1, Global.pdata, multiplayer.get_unique_id(), Steam.getSteamID())


func on_peer_left(pid) -> void :
    players.erase(pid)
    SignalBus.player_left.emit(pid)
    print("%s has left the game" % pid)

func client_disconnect() -> void :
    lobby_id = 0
    players.clear()
    peer = null
    multiplayer.multiplayer_peer = null
    get_tree().change_scene_to_file("res://assets/scenes/main_menu.tscn")
    print("you have left the game.")



func on_steam_lobby_created(result: int, new_lobby_id: int) -> void :
    if result == Steam.Result.RESULT_OK:
        lobby_id = new_lobby_id

        peer = SteamMultiplayerPeer.new()
        peer.debug_level = SteamMultiplayerPeer.DEBUG_LEVEL_PEER
        peer.host_with_lobby(lobby_id)
        multiplayer.multiplayer_peer = peer
        DisplayServer.clipboard_set(str(lobby_id))
        setup_player(Global.pdata, 1, Steam.getSteamID())

func on_steam_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, _response: int) -> void :
    if Steam.getLobbyOwner(this_lobby_id) == Steam.getSteamID():

        return


    peer = SteamMultiplayerPeer.new()
    peer.debug_level = SteamMultiplayerPeer.DEBUG_LEVEL_PEER
    peer.connect_to_lobby(this_lobby_id)
    multiplayer.multiplayer_peer = peer
    setup_player.rpc_id(1, Global.pdata, multiplayer.get_unique_id(), Steam.getSteamID())
