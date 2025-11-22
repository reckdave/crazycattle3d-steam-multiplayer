extends Control

@onready var lobby_game: PackedScene = preload("res://assets/scenes/lobby.tscn")

var lobby_type: Enums.server_type = Enums.server_type.steam

func _on_join_pressed() -> void :
    MultiplayerHandler.join_server(lobby_type, $ADDRESS.text)
    get_tree().change_scene_to_packed(lobby_game)

func _on_create_pressed() -> void :
    MultiplayerHandler.create_server(lobby_type)
    get_tree().change_scene_to_packed(lobby_game)

func _on_servertype_item_selected(index: int) -> void :
    lobby_type = index

func _on_exit_pressed() -> void :
    hide()
    %Start.show()
