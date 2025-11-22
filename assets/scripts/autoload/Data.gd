extends Node

var data: DataFile = DataFile.new()

func save() -> void :
	SignalBus.data_saved.emit()
	ResourceSaver.save(data, data.FILE_PATH)

func get_data() -> DataFile:
	return data

func load_data() -> void :
	if not FileAccess.file_exists(data.FILE_PATH):
		save()
	data = ResourceLoader.load(data.FILE_PATH).duplicate(true)

func _ready() -> void :
	load_data()
	print(data.game.wins)
	Global.pdata.username = data.settings.username
	Global.pdata.cosmetics = data.game.cosmetics

func give_achievement(ach_name: String):
	if data.game.achievements[ach_name] == true:
		return
	data.game.achievements[ach_name] = true
	Notif.notify("You just unlocked the achievement %s!" % ach_name, 5)
	save()
