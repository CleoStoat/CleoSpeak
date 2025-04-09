extends Control


@onready var player := %AudioStreamPlayer

const PYTHONPROJECT_PATH = ".\\pythonproject\\"

func _ready() -> void:
	%TTSTab.reload_presets()


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var file_path = "user://tts_hello.mp3"
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		
		play_audio(file_path)
		#var json = JSON.parse_string(body.get_string_from_utf8())
		#if json and json.has("file_path"):
			#var file_path = PYTHONPROJECT_PATH + json["file_path"]
			#print(file_path)
			#play_audio(file_path)

func play_audio(file_path: String):
	player.stream = load_mp3(file_path)
	player.play()

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


func _on_preset_config_tab_presets_saved() -> void:
	%TTSTab.reload_presets()


func _on_tts_tab_tts_submited(text: String, preset: Preset) -> void:
	#if not TTSPythonServer.is_process_alive():
		#print("TTS server is not running")
		#return
	
	var headers = ["Content-Type: application/json"]
	var url = "http://127.0.0.1:" + str(TTSPythonServer.server_port) + "/generate"
	
	var data = {
		"text": text, 
		"voice_provider": preset.voice_provider, 
		"voice_language": preset.voice_language, 
		"slow": preset.slow
	}
	var body = JSON.stringify(data)
	%HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body)


func _on_health_check_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response and response["status"] == "ok":
			print("✅ TTS API is running!")
			# You could trigger your TTS request here
		else:
			print("⚠️ Unexpected health check response:", response)
	else:
		print("❌ Health check failed with code:", response_code)
