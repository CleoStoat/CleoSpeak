extends Control

var presets: Array[Preset] = []

signal tts_submited

func read_presets_file():
	var file = FileAccess.open("res://presets.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
	
func reload_presets():
	presets.assign([])
	for preset_str in read_presets_file():
		var preset = Preset.new(
			preset_str["name"],
			preset_str["voice_provider"],
			preset_str["voice_language"],
			preset_str["slow"]
		)
		presets.append(preset)
	update_select_preset_option_button()


func update_select_preset_option_button():
	%SelectPrestOptionButton.clear()
	for index in presets.size():
		%SelectPrestOptionButton.add_item(presets[index].name)

func get_selected_preset_index():
	return %SelectPrestOptionButton.get_selected_id()

func _on_tts_submit_button_pressed() -> void:
	var text : String= %TTSTextEdit.text
	if text.is_empty():
		return
	
	var preset_index = get_selected_preset_index()
	if preset_index == -1:
		return
	
	emit_signal("tts_submited", text, presets[preset_index])
