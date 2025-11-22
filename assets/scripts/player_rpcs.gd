extends Node

@onready var player: Player = get_owner()

@rpc("authority", "call_local", "reliable")
func die() -> void :
	player.local_death_set()

@rpc("authority", "call_local", "reliable")
func bahh() -> void :
	%SFX.get_node("baa").play()
