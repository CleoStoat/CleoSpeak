extends Control

func _ready() -> void:
	%TTSTab.reload_presets()

func _on_preset_config_tab_presets_saved() -> void:
	%TTSTab.reload_presets()

func _on_tts_tab_tts_submited(text: String, preset: Preset) -> void:
	%Pet.preset = preset
	
	%Pet.queue_tts_request(text)


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
