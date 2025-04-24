extends Node

const discord_app = 1365025198646235268

func _update_rpc(players):
	DiscordRPC.app_id = discord_app
	DiscordRPC.state = "Playing";
	DiscordRPC.details = "Knocking over sheep.";
	#DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system());
	#DiscordRPC.end_timestamp = 1507665886;
	DiscordRPC.large_image = "crazy_icon";
	DiscordRPC.large_image_text = "Cattle";
	DiscordRPC.small_image = "icon_svg";
	DiscordRPC.small_image_text = "Made in Godot";
	#DiscordRPC.party_id = "ae488379-351d-4a4f-ad32-2b9b01c91657";
	DiscordRPC.current_party_size = 1;
	DiscordRPC.max_party_size = 32;
	#DiscordRPC.join_secret = "MTI4NzM0OjFpMmhuZToxMjMxMjM= ";
	
	DiscordRPC.refresh()

func _enter_tree() -> void:
	_update_rpc(1)

func _ready() -> void:
	_update_rpc(1)
