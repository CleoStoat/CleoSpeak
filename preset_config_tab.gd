extends Control


@onready var select_preset_option_button := %SelectPresetOptionButton
@onready var delete_preset_button := %DeletePresetButton
@onready var preset_name_line_edit := %PresetNameLineEdit
@onready var voice_language_line_edit := %VoiceLanguageLineEdit
@onready var voice_language_item_list := %VoiceLanguageItemList
@onready var selected_voice_label := %SelectedVoiceLabel
@onready var slow_check_button := %SlowCheckButton
@onready var tts_provider_option_button := %TTSProviderOptionButton

var edge_tts_raw_voices_list: Array
var gtts_raw_voices_list: Dictionary
var gtts_voice_languages = []
var edge_tts_voice_languages = []


var presets: Array[Preset] = []

signal presets_saved

func update_select_preset_display_data(selected: int = select_preset_option_button.selected):
	select_preset_option_button.clear()
	for id in presets.size():
		select_preset_option_button.add_item(presets[id].name)
	select_preset_option_button.select(selected)

func add_preset(preset: Preset):
	presets.append(preset)

func remove_preset(preset_id: int):
	# TO-DO: validate id
	presets.remove_at(preset_id)

func get_selected_preset_index() -> int:
	return select_preset_option_button.selected


func _ready() -> void:
	for preset_str in read_presets_file():
		var preset = Preset.new(
			preset_str["name"],
			preset_str["voice_provider"],
			preset_str["voice_language"],
			preset_str["slow"]
		)
		add_preset(preset)
	update_select_preset_display_data()
	
	
	edge_tts_raw_voices_list = read_edge_voices_list()["voice_languages"]
	for voice in edge_tts_raw_voices_list:
		edge_tts_voice_languages.append(voice["ShortName"])
	
	gtts_raw_voices_list = read_gtts_voices_list()["voice_languages"]
	gtts_voice_languages.assign(gtts_raw_voices_list.keys())


func _on_create_new_preset_button_pressed() -> void:
	add_preset(Preset.new())
	update_select_preset_display_data()

func _on_delete_preset_button_pressed() -> void:
	var selected_index = select_preset_option_button.selected
	if selected_index == -1:
		return
	remove_preset(selected_index)
	update_select_preset_display_data()
	
	select_preset_option_button.emit_signal("item_selected", -1)


func _on_select_preset_option_button_item_selected(index: int) -> void:
	if index == -1:
		# Clear data from fields and disable
		pass
	else:
		var preset = presets[index]
		
		preset_name_line_edit.text = preset.name
		
		if preset.voice_provider == "gtts":
			tts_provider_option_button.selected = 0
		elif preset.voice_provider == "edge":
			tts_provider_option_button.selected = 1
		
		update_voice_list()
		update_selected_voice_label()
		slow_check_button.button_pressed = preset.slow
		clear_voice_filter_text()

func get_voice_language_filter_text():
	return voice_language_line_edit.text

func clear_voice_filter_text():
	voice_language_line_edit.clear()

func update_voice_list():
	voice_language_item_list.clear()
	var index = get_selected_preset_index()
	if index == -1:
		return
	var preset = presets[index]
	
	var available_voice_langs: Array[String] = []
	if preset.voice_provider == "gtts":
		available_voice_langs.assign(gtts_voice_languages.duplicate())
	elif preset.voice_provider == "edge":
		available_voice_langs.assign(edge_tts_voice_languages.duplicate())
	
	
	var filter = get_voice_language_filter_text()
	var filtered_voice_langs = available_voice_langs.filter(
		func(voice: String): 
			return voice.to_lower().begins_with(filter.to_lower())
	)
	
	for voice_index in filtered_voice_langs.size():
		voice_language_item_list.add_item(filtered_voice_langs[voice_index])
		if filtered_voice_langs[voice_index] == preset.voice_language:
			voice_language_item_list.select(voice_index)

func _on_preset_name_line_edit_text_changed(new_text: String) -> void:
	var index = get_selected_preset_index()
	if index == -1:
		return
	else:
		presets[index].name = new_text
		update_select_preset_display_data()



func _on_voice_language_line_edit_text_changed(new_text: String) -> void:
	update_voice_list()


func _on_tts_provider_option_button_item_selected(index: int) -> void:
	var preset = presets[get_selected_preset_index()]
	if index == 0:
		preset.voice_provider = "gtts"
	elif index == 1:
		preset.voice_provider = "edge"
	clear_voice_filter_text()
	update_voice_list()

func update_selected_voice_label():
	var index = get_selected_preset_index()
	if index == -1:
		selected_voice_label.text = ""
	else:
		selected_voice_label.text = presets[index].voice_language

func _on_voice_language_item_list_item_selected(index: int) -> void:
	if index == -1:
		return
	else:
		var preset_index = get_selected_preset_index()
		if preset_index == -1:
			return
		else:
			presets[preset_index].voice_language = voice_language_item_list.get_item_text(index)
			update_selected_voice_label()

func _on_slow_check_button_pressed() -> void:
	var index = get_selected_preset_index()
	if index == -1:
		return
	else:
		presets[index].slow = slow_check_button.button_pressed


func save_presets_to_file():
	var file = FileAccess.open("res://presets.json", FileAccess.WRITE)
	file.store_string(Preset.serialize(presets))


func _on_save_preset_button_pressed() -> void:
	save_presets_to_file()
	emit_signal("presets_saved")

func read_edge_voices_list():
	var file = FileAccess.open("res://edge_voices.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func read_gtts_voices_list():
	var file = FileAccess.open("res://gtts_voices.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

func read_presets_file():
	var file = FileAccess.open("res://presets.json", FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
