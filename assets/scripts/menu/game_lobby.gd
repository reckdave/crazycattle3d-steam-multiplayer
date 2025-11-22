extends Control

func _on_start_pressed() -> void :
    GameHandler.start_game.rpc()

func _on_exit_pressed() -> void :
    MultiplayerHandler.client_disconnect()
