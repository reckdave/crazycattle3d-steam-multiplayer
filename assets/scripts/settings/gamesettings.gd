extends Control

func _on_user_text_submitted(new_name: String) -> void :
    Data.data.settings.username = new_name
    Global.pdata.username = new_name
    Data.save()

func _on_resetdata_pressed() -> void :
    Data.data = DataFile.new()
    Data.save()

    OS.alert("YOUR GAMES DATA HAS BEEN RESET. REOPEN THE GAME", "WARNING.")
    get_tree().quit()
