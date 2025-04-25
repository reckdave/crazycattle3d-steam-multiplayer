extends Node

var game_dir : String = OS.get_executable_path().get_base_dir()
var settings_file : String = game_dir + "/settings.json"

var data : Dictionary = {}
var default_data : Dictionary = {
	"GRAPHICS": 0
}

func set_key(key,val):
	data[key] = val

func _save():
	var file : FileAccess = FileAccess.open(settings_file,FileAccess.WRITE)
	file.store_string(JSON.stringify(data,"\t"))

func _ready() -> void:
	var file : FileAccess
	if !(FileAccess.file_exists(settings_file)): # it doesnt exist bru
		file = FileAccess.open(settings_file,FileAccess.WRITE)
		file.store_string(JSON.stringify(default_data,"\t"))
		data = default_data
		print("created, %s" % data)
	else:
		file = FileAccess.open(settings_file,FileAccess.READ)
		data = str_to_var(file.get_as_text())
		print("found, %s" % data)
	file.close()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()
