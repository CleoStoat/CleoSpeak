extends Node

var server_pid: int = -1
var server_port: int = 8080

const VENV_PYTHON_EXE = ".\\pythonproject\\venv\\Scripts\\python.exe"
const MAIN_PATH = ".\\pythonproject\\main.py"


func start_server():
	var args = ["-m", "fastapi", "run", MAIN_PATH, "--port", str(server_port)]
	server_pid = OS.create_process(VENV_PYTHON_EXE, args, true)
	
	if server_pid == -1:
		print("Failed to start process")
	else:
		print("Started process with PID:", server_pid)

# Check if the process is still alive
func is_process_alive() -> bool:
	return OS.is_process_running(server_pid)

# Terminate the process
func terminate_process():
	if server_pid == -1:
		print("No process to terminate")
		return
	elif not is_process_alive():
		print("Process is not running")
	else:
		OS.kill(server_pid)
		print("Process terminated")

func restart_server():
	print("Stopping current process...")
	terminate_process()
	print("Starting new process...")
	start_server()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		terminate_process()
		get_tree().quit()
