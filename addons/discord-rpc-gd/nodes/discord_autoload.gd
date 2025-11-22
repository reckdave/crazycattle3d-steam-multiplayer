





extends Node

func setup_discord():
    DiscordRPC.app_id = 1365025198646235268
    DiscordRPC.state = "Playing";
    DiscordRPC.details = "Knocking over sheep.";


    DiscordRPC.large_image = "crazy_icon";
    DiscordRPC.large_image_text = "Cattle";
    DiscordRPC.small_image = "icon_svg";
    DiscordRPC.small_image_text = "Made in Godot";
    DiscordRPC.refresh()
    print("updated")

func _ready() -> void :
    setup_discord()

func _process(_delta) -> void :
    DiscordRPC.run_callbacks()
