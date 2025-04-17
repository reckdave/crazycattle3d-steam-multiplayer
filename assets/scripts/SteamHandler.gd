extends Node

const steam_appid : int = 480

func _init() -> void:
	OS.set_environment("SteamAppId", str(steam_appid))
	OS.set_environment("SteamGameId", str(steam_appid))

func _ready() -> void:
	Steam.steamInit()
	Steam.restartAppIfNecessary(steam_appid)

func _process(delta: float) -> void:
	Steam.run_callbacks()
