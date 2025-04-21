extends Node3D
class_name Player

@export var sheep_speed : float = 100.0
var tick_rate : int = 0

#region playerdata
var dead : bool = false:
	set(val):
		
		$Controller.freeze = val
		$Controller/Collision.disabled = val
		$Controller/sheepmodel.visible = !val
		
		
		$Controller.engine_force = 0.0
		$Controller.steering = 0.0
		
		dead = val

var infreecam : bool = false:
	set(val):
		if (is_multiplayer_authority()):
			$Controller/Camera.current = !val
			$FreeCam.current = val
		if val:
			%FreeCam.global_position = $Controller.global_position + Vector3(0,5,0)
			%player_display.reparent(%FreeCam,false)
		else:
			%player_display.reparent($Controller,false)
		infreecam = val
var username : String = "steamuser99":
	set(val):
		%player_display.text = val
		username = val
#endregion

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	%player_display.text = MultiplayerHandler.players[int(name)]["username"]
	multiplayer.peer_disconnected.connect(_on_player_leave)
	
	
	if !(is_multiplayer_authority()):$UI.hide(); $SettingsMenu.hide(); return
	$Controller/Camera.current = true
	%player_display.hide()
	global_position = Vector3(randi_range(-80,80),1,randi_range(-80,80))
func _unhandled_input(event: InputEvent) -> void:
	if !(is_multiplayer_authority()): return
	if (infreecam) and event is InputEventMouseMotion:
		var look_dir = event.relative * 0.01
		%FreeCam.rotation.y -= look_dir.x * 1.0 * 1.0
		%FreeCam.rotation.x = clamp(%FreeCam.rotation.x - look_dir.y * 1.0 * 1.0, -1.5, 1.5)

func _physics_process(delta: float) -> void:
	if not (is_multiplayer_authority()): set_physics_process(false); return
	if Input.is_action_just_pressed("debug_die"): die.rpc()
	#if Input.is_action_just_pressed("debug_respawn"): respawn.rpc()
	if !(dead):
		#if !(has_node("Controller")): return
		$Controller.steering = lerp($Controller.steering, Input.get_axis("left", "right") * 0.4, 5 * delta)
		$Controller.engine_force = Input.get_axis("back", "forward") * sheep_speed
		
		setcarforce.rpc($Controller.engine_force,$Controller.steering)
		tick_rate += 1
		
		if tick_rate >= 8 :
			setcardata.rpc($Controller.global_position,$Controller.global_rotation)
		
		if Input.is_action_just_pressed("space"):
			$Controller.linear_velocity = Vector3(0,20,0)
			baa_sound.rpc()
	elif (infreecam) and (dead):
		var input_dir = Input.get_vector("left","right","forward","back")
		var forward_dir = %FreeCam.global_transform.basis * Vector3(input_dir.x,0,input_dir.y).normalized()
		
		if (Input.is_action_pressed("space")): %FreeCam.global_position.y += 1.0
		if (Input.is_action_pressed("control")): %FreeCam.global_position.y -= 1.0
		
		%FreeCam.global_position.x += forward_dir.x * 0.6
		%FreeCam.global_position.z += forward_dir.z * 0.6
		setfreecamdata.rpc(%FreeCam.global_position)

var can_try : bool = false
var try_time : float = 1

func _process(delta: float) -> void:
	$UI/Control/Remaining.text = "%s left alive." % str(GameHandler.alive_players.size())
	if (Input.is_action_just_pressed("ui_down")): GameHandler.world_node.get_node("Map/DeathBarriar").queue_free()
	if !(multiplayer.is_server()):
		return
	else:
		try_time -= delta;
	if !(can_try): 
		if (try_time <= 0): can_try = true
		return
	
	var dead_collide = %death_ray.is_colliding()
	var death_area_collide = $Controller/DeathArea.get_overlapping_bodies().size()
	var inside_zone = $Controller/ZoneArea.get_overlapping_areas().size()
	
	if !(dead):
		if (dead_collide) or (inside_zone <= 0) or (death_area_collide > 0):
			die.rpc()
# multiplayer calls

#@rpc("any_peer","call_local","reliable",0)
#func push_collide(body):
	#if (multiplayer.get_remote_sender_id() != 1): return
	#body.apply_impulse($Controller.linear_velocity)

@rpc("authority","call_remote","unreliable",0)
func setcardata(newpos,newrot):
	if !(has_node("Controller")): return
	$Controller.global_position = lerp($Controller.global_position,newpos,0.4)
	$Controller.global_rotation = newrot

@rpc("authority","call_remote","unreliable",0)
func setcarforce(newforce,newsteer):
	if !(has_node("Controller")): return
	$Controller.engine_force = newforce
	$Controller.steering = newsteer

@rpc("authority","call_remote","unreliable",0)
func setfreecamdata(newpos):
	%FreeCam.global_position = newpos
@rpc("authority","call_local","unreliable",0)
func baa_sound():
	if !(has_node("Controller")): return
	$Controller/SFX/Baa.play()

#@rpc("authority","call_local","reliable",0)
#func userdata(Pusername,Pdead,Pinfreecam):
#	username = Pusername
#	dead = Pdead
#	infreecam = Pinfreecam
#	
#	$Controller/theghoul.hide()
#	if (username == "") or (username == "steamuser99"):
#		$Controller/theghoul.show()

@rpc("any_peer","call_local","reliable",0)
func die():
	if (multiplayer.get_remote_sender_id() != 1): return
	if !(has_node("Controller")): return
	
	if !(dead):
		print("%s HAS DIED" % username)
		
		$Controller/VFX/Explosion.play("Explode")
		$Controller/SFX/Explode.play()
		$Controller/SFX/Death1.play()
		
		sheep_speed = 0.0
		
		infreecam = true
		dead = true
		GameHandler.alive_players.erase(int(name))
		GameHandler.player_removed.emit(int(name))

#@rpc("authority","call_local","reliable",0)
#func respawn():
#	if (dead):
#		print("revive %s" % username)
#		
#		$Controller.global_rotation = Vector3(0,0,0)
#		$Controller.global_position = Vector3(0,2,0)
#		$Controller/VFX/Explosion.play("NONE")
#		
#		sheep_speed = 100.0
#		dead = false
#		infreecam = false
		
		#setcardata.rpc($Controller.global_position,$Controller.global_rotation)

# multiplayer connects
func _on_player_leave(pid):
	if pid == int(name):
		if GameHandler.alive_players.has(pid): GameHandler.alive_players.erase(pid); GameHandler.player_removed.emit(int(name))
		queue_free()


#func _on_collision_bump_area_entered(area: Area3D) -> void:
	#print(area.get_parent().name)
	#if !(multiplayer.is_server()): return
	#push_collide.rpc(area.get_parent())

# MISC
func _on_chat_type_text_submitted(new_text: String) -> void:
	#send_message.rpc(new_text)
	pass
