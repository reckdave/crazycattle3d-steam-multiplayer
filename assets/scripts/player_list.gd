extends HFlowContainer

func add_player(pid: int):
	var pdata: Dictionary = MultiplayerHandler.players[pid]
	var player_button: Button = Button.new()

	player_button.text = pdata.username
	player_button.name = str(pid)
	add_child(player_button)

func load_players():
	for existing_players in get_children():
		existing_players.queue_free()

	for ingame_player in MultiplayerHandler.players:
		add_player(ingame_player)

func left(pid: int):
	get_node(str(pid)).queue_free()

func _ready() -> void :
	SignalBus.player_joined.connect(add_player)
	SignalBus.player_left.connect(left)
	load_players()
