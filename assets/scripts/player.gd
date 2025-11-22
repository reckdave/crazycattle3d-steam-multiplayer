extends Node3D
class_name Player

@onready var controller: VehicleBody3D = $Controller

var username: String = "steamuser99"
var pid: int = 1
var steamID: int = 0
var cosmetics: Array = []

var sheep_force: float = 100.0

var dead: bool = false
var state: Enums.player_states = Enums.player_states.normal

func _enter_tree() -> void :
	set_multiplayer_authority(pid)

func setup_cosmetics():
	for cosmetic in cosmetics:
		var model = get_node_or_null("%Cosmetics/" + cosmetic)
		if model:
			model.show()

func _ready() -> void :
	Util.set_processes(self, false)

	name = str(pid)
	controller.get_node("usernameLabel").text = username
	setup_cosmetics()
	if not is_multiplayer_authority(): return

	Global.player = self
	controller.get_node("usernameLabel").hide()
	controller.get_node("Camera").current = true
	controller.global_position = Vector3(randf_range(-40, 40), 5, randf_range(-40, 40))
	Util.set_processes(self, true)

func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion and state == Enums.player_states.spectating:
		var look_dir = event.relative * 0.01
		%Freecam.rotation.y -= look_dir.x * 1.0 * 1.0
		%Freecam.rotation.x = clamp( %Freecam.rotation.x - look_dir.y * 1.0 * 1.0, -1.5, 1.5)

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("mute"):
		$Controller/VoicechatHandler.speak = not $Controller/VoicechatHandler.speak
		$UI/Mic.visible = not $Controller/VoicechatHandler.speak
	if event.is_action_pressed("escape"):
		%PauseMenu.visible = ! %PauseMenu.visible

func _physics_process(delta: float) -> void :
	match (state):
		Enums.player_states.normal:
			controller.steering = lerp(controller.steering, Input.get_axis("left", "right") * 0.4, 5 * delta)
			controller.engine_force = Input.get_axis("backwards", "forward") * sheep_force

			var deathRayColliding: bool = controller.get_node("deathRay").is_colliding()

			if deathRayColliding:
				local_death()

			if Input.is_action_just_pressed("space"):
				%RPCS.bahh.rpc()
		Enums.player_states.spectating:
			%Freecam.current = true
			var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backwards")
			var move_dir: Vector3 = ( %Freecam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

			%Freecam.global_position.x += move_dir.x * 0.6
			%Freecam.global_position.z += move_dir.z * 0.6

func _on_death_area_body_entered(body: Node3D) -> void :
	if not is_multiplayer_authority(): return
	Data.give_achievement("Noob.")
	local_death()

func local_death() -> void :
	if dead: return
	state = Enums.player_states.spectating
	%RPCS.die.rpc()

func local_death_set() -> void :
	if dead: return
	dead = true
	controller.freeze = true
	controller.get_node("CollisionShape3D").call_deferred("queue_free")
	controller.get_node("usernameLabel").reparent( %Freecam, false)
	SignalBus.player_died.emit(pid)

	%Freecam.global_position = controller.global_position + Vector3(0, 5, 0)

	%sheepmodel.hide()
	%Cosmetics.hide()
	%VFX.get_node("Explosion").play("Explosion")
	%SFX.get_node("explode").play()

@rpc("any_peer", "call_local", "reliable")
func force_kill():
	if multiplayer.get_remote_sender_id() != 1: return
	local_death_set()
