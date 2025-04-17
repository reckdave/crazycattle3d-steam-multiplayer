extends Node

const steam_appid : int = 480

var steamName : String

func _ready() -> void:
	OS.set_environment("SteamAppId", str(steam_appid))
	OS.set_environment("SteamGameId", str(steam_appid))
	Steam.steamInitEx()
	
	steamName = Steam.getPersonaName()

func _process(delta: float) -> void:
	Steam.run_callbacks()
