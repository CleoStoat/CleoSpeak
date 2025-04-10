extends Control


func _on_open_button_pressed() -> void:
	%Window.show()


func _on_window_close_requested() -> void:
	%Window.hide()
