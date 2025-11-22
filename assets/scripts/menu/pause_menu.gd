extends Control

func _on_leave_pressed() -> void :
	MultiplayerHandler.client_disconnect()

func _on_settings_pressed() -> void :
	%SettingsMenu.show()
