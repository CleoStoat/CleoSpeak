extends Control

@onready var select_preset_option_button := %SelectPresetOptionButton
@onready var delete_preset_button := %DeletePresetButton

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
	
