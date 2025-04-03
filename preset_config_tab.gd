extends Control

@onready var select_preset_option_button := %SelectPresetOptionButton
@onready var delete_preset_button := %DeletePresetButton
@onready var preset_name_line_edit := %PresetNameLineEdit

signal presets_changed(new_presets: Array[Preset])

var _presets: Array[Preset] = []

var presets: Array[Preset]:
	get:
		return _presets
	set(value):
		_presets = value
		emit_signal("presets_changed", _presets)

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


func _on_preset_name_line_edit_text_submitted(new_text: String) -> void:
	var index = select_preset_option_button.selected
	if index == -1:
		return
	else:
		presets[index].name = new_text
		repopulate_select_preset()
