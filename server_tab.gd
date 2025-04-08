extends Control

var selected_dir: String = ""
var port: String = ""

func _on_select_folder_button_pressed() -> void:
	%SelectFolderFileDialog.show()


func _on_select_folder_file_dialog_confirmed() -> void:
	%CurrentFolderLabel.text = selected_dir

func _on_select_folder_file_dialog_dir_selected(dir: String) -> void:
	selected_dir = dir
	

func _on_port_line_edit_text_changed(new_text: String) -> void:
	port = new_text


func _on_restart_server_button_pressed() -> void:
	TTSPythonServer.restart_server()
