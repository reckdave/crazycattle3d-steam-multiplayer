extends Node3D

var current_sample_rate: int = 48000
var has_loopback: bool = true
var local_playback: AudioStreamGeneratorPlayback = null
var local_voice_buffer: PackedByteArray = PackedByteArray()
var network_playback: AudioStreamGeneratorPlayback = null
var network_voice_buffer: PackedByteArray = PackedByteArray()
var packet_read_limit: int = 5

func _ready() -> void:
	$Local.stream.mix_rate = current_sample_rate
	$Local.play()
	local_playback = $Local.get_stream_playback()

	$Network.stream.mix_rate = current_sample_rate
	$Network.play()
	network_playback = $Network.get_stream_playback()
	
	if (is_multiplayer_authority()):
		#$Local.volume_db = -9999
		Steam.startVoiceRecording()

func _process(_delta: float) -> void:
	if !(is_multiplayer_authority()): return
	check_for_voice()

func check_for_voice() -> void:
	var available_voice: Dictionary = Steam.getAvailableVoice()

	# Seems there is voice data
	if available_voice['result'] == Steam.VOICE_RESULT_OK and available_voice['buffer'] > 0:
		# Valve's getVoice uses 1024 but GodotSteam's is set at 8192?
		# Our sizes might be way off; internal GodotSteam notes that Valve suggests 8kb
		# However, this is not mentioned in the header nor the SpaceWar example but -is- in Valve's docs which are usually wrong
		var voice_data: Dictionary = Steam.getVoice()
		if voice_data['result'] == Steam.VOICE_RESULT_OK and voice_data['written']:
			print("Voice message has data: %s / %s" % [voice_data['result'], voice_data['written']])

			# Here we can pass this voice data off on the network
			#Networking.send_message(voice_data['buffer'])

			# If loopback is enable, play it back at this point
			if has_loopback:
				print("Loopback on")
				process_voice_data.rpc(voice_data,"local")

func get_sample_rate() -> void:
	current_sample_rate = Steam.getVoiceOptimalSampleRate()
	print("Current sample rate: %s" % current_sample_rate)

@rpc("any_peer","call_local","unreliable")
func process_voice_data(voice_data: Dictionary, voice_source: String) -> void:
	# Our sample rate function above without toggling
	get_sample_rate()

	var decompressed_voice: Dictionary = Steam.decompressVoice(voice_data['buffer'], current_sample_rate)

	if decompressed_voice['result'] == Steam.VOICE_RESULT_OK and decompressed_voice['size'] > 0:
		print("Decompressed voice: %s" % decompressed_voice['size'])

		if voice_source == "local":
			local_voice_buffer = decompressed_voice['uncompressed']
			local_voice_buffer.resize(decompressed_voice['size'])

			# We now iterate through the local_voice_buffer and push the samples to the audio generator
			for i: int in range(0, mini(local_playback.get_frames_available() * 2, local_voice_buffer.size()), 2):
				# Steam's audio data is represented as 16-bit single channel PCM audio, so we need to convert it to amplitudes
				# Combine the low and high bits to get full 16-bit value
				var raw_value: int = local_voice_buffer[0] | (local_voice_buffer[1] << 8)
				# Make it a 16-bit signed integer
				raw_value = (raw_value + 32768) & 0xffff
				# Convert the 16-bit integer to a float on from -1 to 1
				var amplitude: float = float(raw_value - 32768) / 32768.0

				# push_frame() takes a Vector2. The x represents the left channel and the y represents the right channel
				local_playback.push_frame(Vector2(amplitude, amplitude))

				# Delete the used samples
				local_voice_buffer.remove_at(0)
				local_voice_buffer.remove_at(0)
