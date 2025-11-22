extends Node3D

@onready var targetEmitter = $Voice
@export var targetPlayer:Player
@export var _talkingSprite:Sprite3D

var _voiceBuffer: PackedByteArray = PackedByteArray()
var _playback:AudioStreamGeneratorPlayback = null
var _hasLoopback: bool = true

var speaking:bool = false
var speak:bool = true



const targetRate:int = 11025


func _ready() -> void:
	set_multiplayer_authority(
		targetPlayer.get_multiplayer_authority()
	)
	
	var audioGenerator:AudioStreamGenerator = AudioStreamGenerator.new()
	audioGenerator.mix_rate = targetRate
		
	targetEmitter.stream = audioGenerator
	targetEmitter.play()
	
	_playback = targetEmitter.get_stream_playback()
	
	assert(targetEmitter != null, "Target emitter must be valid")
	assert(targetPlayer != null, "Target player must be valid")
	
	if !is_multiplayer_authority():
		return
		
		
	print("starting voice")
	Steam.startVoiceRecording()
	
	
@rpc("any_peer", "call_remote", "unreliable")
func _processVoice(voiceData:Dictionary) -> void:
	var decompressedVoice: Dictionary = Steam.decompressVoice(voiceData["buffer"], targetRate)
	
	if decompressedVoice["result"] == Steam.VOICE_RESULT_OK and decompressedVoice["size"] > 0:
		
		_voiceBuffer = decompressedVoice['uncompressed']
		_voiceBuffer.resize(decompressedVoice['size'])
		
		#print(decompressedVoice['size'])
		
		
		if _playback == null:
			return
		
		for i: int in range(0, mini(_playback.get_frames_available() * 2, _voiceBuffer.size()), 2):
			var raw_value: int = _voiceBuffer[0] | (_voiceBuffer[1] << 8)
			raw_value = (raw_value + 32768) & 0xffff
			
			var amplitude: float = float(raw_value - 32768) / 32768.0
			_playback.push_frame(Vector2(amplitude, amplitude))
			
			_voiceBuffer.remove_at(0)
			_voiceBuffer.remove_at(0)
			continue
			
		
	return
	
func _checkVoice() -> void:
	var voiceData: Dictionary = Steam.getVoice()
	
	if voiceData["result"] == Steam.VOICE_RESULT_OK and voiceData["written"]:
		if _hasLoopback:
			_processVoice.rpc(voiceData)
	return
	
	
	
func _process(_delta: float) -> void:
	
	if _playback == null:
		return
	
	if not speak:
		return
	
	var frames:float = _playback.get_frames_available()/float(targetRate)
	#print(frames)
	
	speaking = frames < 0.74
	
	if _talkingSprite:
		_talkingSprite.visible = speaking
	
	
	if !is_multiplayer_authority():
		return
		
	_checkVoice()
	return
