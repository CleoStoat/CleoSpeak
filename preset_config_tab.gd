extends Control

@onready var select_preset_option_button := %SelectPresetOptionButton
@onready var delete_preset_button := %DeletePresetButton
@onready var preset_name_line_edit := %PresetNameLineEdit
@onready var voice_language_line_edit := %VoiceLanguageLineEdit
@onready var voice_language_item_list := %VoiceLanguageItemList
@onready var selected_voice_label := %SelectedVoiceLabel
@onready var slow_check_button := %SlowCheckButton
@onready var tts_provider_option_button := %TTSProviderOptionButton

const GTTS_VOICE_LANGUAGES = ["one", "two", "three", "four"]
const EDGE_TTS_VOICE_LANGUAGES = ["1", "2", "3", "4"]

signal presets_changed(new_presets: Array[Preset])
var _presets: Array[Preset] = []

var presets: Array[Preset]:
	get:
		return _presets
	set(value):
		_presets = value
		emit_signal("presets_changed", _presets)

signal selected_preset_index_changed(new_index: int)
var _selected_preset_index: int

var selected_preset_index: int:
	get:
		return _selected_preset_index
	set(value):
		_selected_preset_index = value
		emit_signal("selected_preset_index_changed", _selected_preset_index)

var available_voice_languages: Array[String] = []

var selected_preset: Preset:
	get:
		var index = select_preset_option_button.selected
		if index == -1:
			return null
		else:
			return presets[index]

func _ready() -> void:
	repopulate_select_preset()

func repopulate_select_preset():
	var selected = select_preset_option_button.selected
	
	select_preset_option_button.clear()
	for preset in presets:
		select_preset_option_button.add_item(preset.name)
	
	select_preset_option_button.selected = selected

func _on_create_new_preset_button_pressed() -> void:
	var new_presets = presets.duplicate()
	new_presets.append(Preset.new())
	presets = new_presets
	print(presets)


func _on_presets_changed(new_presets: Array[Preset]) -> void:
	repopulate_select_preset()


func _on_delete_preset_button_pressed() -> void:
	var selected_index = select_preset_option_button.selected
	
	if selected_index == -1:
		return
	
	var new_presets = presets.duplicate()
	new_presets.remove_at(selected_index)
	
	presets = new_presets
	
	# Select -1 to clear selection
	select_preset_option_button.selected = -1
	select_preset_option_button.emit_signal("item_selected", select_preset_option_button.selected)


func _on_select_preset_option_button_item_selected(index: int) -> void:
	selected_preset_index = index
	print("selected ", index)


func _on_preset_name_line_edit_text_changed(new_text: String) -> void:
	var index = select_preset_option_button.selected
	if index == -1:
		return
	else:
		presets[index].name = new_text
		repopulate_select_preset()



func _on_voice_language_line_edit_text_changed(new_text: String) -> void:
	filter_voices()


func _on_tts_provider_option_button_item_selected(index: int) -> void:
	
	if index == 0:
		selected_preset.voice_provider = "gtts"
	elif index == 1:
		selected_preset.voice_provider = "edge"
	load_voice_language_list()

func load_voice_language_list():
	var voice_languages
	if selected_preset.voice_provider == "gtts":
		voice_languages = GTTS_VOICE_LANGUAGES.duplicate()
	elif selected_preset.voice_provider == "edge":
		voice_languages = EDGE_TTS_VOICE_LANGUAGES.duplicate()
	
	voice_language_line_edit.clear()
	available_voice_languages.assign(voice_languages)
	filter_voices()
	


func filter_voices():
	voice_language_item_list.clear()
	
	var filter = voice_language_line_edit.text
	
	var filtered_voices = available_voice_languages.filter(
		func(voice: String): 
			return voice.to_lower().begins_with(filter.to_lower())
	)
	
	for voice in filtered_voices:
		voice_language_item_list.add_item(voice)

func update_selected_voice_language_label():
	selected_voice_label.text = selected_preset.voice_language

func _on_voice_language_item_list_item_selected(index: int) -> void:
	if index == -1:
		return
	else:
		selected_preset.voice_language = voice_language_item_list.get_item_text(index)
		update_selected_voice_language_label()


func _on_slow_check_button_pressed() -> void:
	selected_preset.slow = slow_check_button.button_pressed

func _on_selected_preset_index_changed(new_index: int) -> void:
	if new_index == -1:
		preset_name_line_edit.text = ""
	else:
		load_preset_for_edit(presets[new_index])

func load_preset_for_edit(preset: Preset):
	preset_name_line_edit.text = preset.name
	
	if preset.voice_provider == "gtts":
		tts_provider_option_button.select(0)
	else: 
		tts_provider_option_button.select(1)
	load_voice_language_list()
	
	update_selected_voice_language_label()
	
	for i in voice_language_item_list.item_count:
		if voice_language_item_list.get_item_text(i) == preset.voice_language:
			voice_language_item_list.select(i)
	
	slow_check_button.button_pressed = preset.slow
	
	
