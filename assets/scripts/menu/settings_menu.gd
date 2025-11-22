extends Control

func _on_exit_pressed() -> void :
	hide()
func _ready() -> void:
	update_category(1)

func update_category(index : int) -> void:
	match index:
		0:
			$Game.show()
			$Audio.hide()
		1:
			$Game.hide()
			$Audio.show()

func _on_category_item_selected(index: int) -> void:
	update_category(index)
