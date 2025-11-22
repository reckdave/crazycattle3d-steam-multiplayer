extends Resource
class_name GameData

@export var first_launch: bool = true
@export var modded: bool = false
@export var loses: int = 0
@export var wins: int = 0
@export var cosmetics: Array = []

@export var achievements: Dictionary[String, bool] = {
	"Absolute Loser" = false,
	"Noob." = false
}
