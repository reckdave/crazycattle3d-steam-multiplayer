extends Node

const steam_appid : int = 480

var steamName : String

func _ready() -> void:
	OS.set_environment("SteamAppId", str(steam_appid))
	OS.set_environment("SteamGameId", str(steam_appid))
	Steam.steamInitEx()
	
	steamName = Steam.getPersonaName()
	Global.player_data.username = steamName
	
	var steam_open = Steam.loggedOn()
	if !steam_open:
		OS.alert("YOU DONT HAVE STEAM OPEN MEANING YOU WONT BE ABLE TO JOIN STEAM LOBBYS","WARNING")
	else:
		print("steam is open")

func _process(_delta: float) -> void:
	Steam.run_callbacks()
