extends Control

@onready var select_preset_option_button := %SelectPresetOptionButton
@onready var delete_preset_button := %DeletePresetButton
@onready var preset_name_line_edit := %PresetNameLineEdit
@onready var voice_language_line_edit := %VoiceLanguageLineEdit
@onready var voice_language_item_list := %VoiceLanguageItemList
@onready var selected_voice_label := %SelectedVoiceLabel
@onready var slow_check_button := %SlowCheckButton

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

var available_voice_languages: Array[String] = []

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
	


func _on_select_preset_option_button_item_selected(index: int) -> void:
	if index == -1:
		preset_name_line_edit.text = ""
	else:
		preset_name_line_edit.text = presets[index].name


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
	voice_language_line_edit.clear()
	var voice_languages
	if index == 0:
		voice_languages = GTTS_VOICE_LANGUAGES.duplicate()
	elif index == 1:
		voice_languages = EDGE_TTS_VOICE_LANGUAGES.duplicate()
	
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



func _on_voice_language_item_list_item_selected(index: int) -> void:
	if index == -1:
		selected_voice_label.text = "None"
	else:
		selected_voice_label.text = voice_language_item_list.get_item_text(index)


func _on_slow_check_button_pressed() -> void:
	pass # Replace with function body.
