extends Control

func _on_settings_pressed() -> void :
    %SettingsMenu.show()

func _on_lobby_pressed() -> void :
    hide()
    %Lobby.show()

func _on_customize_pressed() -> void :
    hide()
    %Customize.show()
