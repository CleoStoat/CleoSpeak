extends Control

@onready var tabs_dict = {
	0: %TTSTab,
	1: %PresetsTab,
	2: %ServerTab,
}

func _ready() -> void:
	pass


func _on_tab_bar_tab_changed(tab: int) -> void:
	for i in tabs_dict:
		if i == tab:
			tabs_dict[i].show()
		else:
			tabs_dict[i].hide()
