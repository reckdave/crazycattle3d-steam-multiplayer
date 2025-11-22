extends Control

func _ready() -> void :
	DiscordRPCLoader.setup_discord()
	if Data.data.game.first_launch:
		Data.data.game.first_launch = false
		Data.data.settings.username = Steam.getPersonaName()
		Data.save()
		OS.alert("WELCOME, to the rewrite of cc3d-steam-multiplayer. Hope you enjoy the new features and such!")
