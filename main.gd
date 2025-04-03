extends Control

@onready var tabs_dict = {
	0: %TTSTab,
	1: %PresetsTab,
	2: %ServerTab,
}

@onready var player := %AudioStreamPlayer

const PYTHONPROJECT_PATH = ".\\pythonproject\\"

signal presets_changed(new_presets: Array[Preset])

var _presets: Array[Preset] = []

var presets: Array[Preset]:
	get:
		return _presets
	set(value):
		_presets = value
		emit_signal("presets_changed", _presets)

func _ready() -> void:
	pass


func _on_tab_bar_tab_changed(tab: int) -> void:
	for i in tabs_dict:
		if i == tab:
			tabs_dict[i].show()
		else:
			tabs_dict[i].hide()


func _on_tts_submit_button_pressed() -> void:
	var tts_text = %TTSTextEdit.text
	var url = "http://127.0.0.1:8000/gtts"
	var headers = ["Content-Type: application/json"]
	var data = {"text": tts_text, "voice_language": "en", "slow": false}
	var body = JSON.stringify(data)
	%HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body)
	


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("file_path"):
			var file_path = PYTHONPROJECT_PATH + json["file_path"]
			print(file_path)
			play_audio(file_path)

func play_audio(file_path: String):
	player.stream = load_mp3(file_path)
	player.play()

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


func _on_create_new_preset_button_pressed() -> void:
	var new_presets = presets.duplicate()
	new_presets.append(Preset.new())
	presets = new_presets
	print(presets)
