extends Node

var audio_queue: Array[AudioQueueItem] = []
var preset: Preset
var queue_index = 0

#{
	#"ready": bool,
	#"audio_file_path": String,
	#"queue_index": int,
#}
class AudioQueueItem:
	var ready: bool
	var audio_file_path: String
	var queue_index: int
	
	func _init(
		_queue_index: int,
		_audio_file_path: String = "",
		_ready: bool = false,
	) -> void:
		ready = _ready
		audio_file_path = _audio_file_path
		queue_index = _queue_index

func set_audio_ready(queue_index: int, audio_file_path: String):
	for i in audio_queue.size():
		if audio_queue[i].queue_index == queue_index:
			audio_queue[i].ready = true
			audio_queue[i].audio_file_path = audio_file_path

func queue_tts_request(text: String):
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed.bind(queue_index, http_request))
	queue_index += 1
	audio_queue.append(AudioQueueItem.new(queue_index))

	var headers = ["Content-Type: application/json"]
	var url = "http://127.0.0.1:" + str(TTSPythonServer.server_port) + "/generate"
	
	var data = {
		"text": text, 
		"voice_provider": preset.voice_provider, 
		"voice_language": preset.voice_language, 
		"slow": preset.slow
	}
	var body = JSON.stringify(data)
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(
		result: int,
		response_code: int,
		headers: PackedStringArray,
		body: PackedByteArray,
		queue_index: int,
		http_request: HTTPRequest,
	) -> void:
	
	if response_code == 200:
		var datetime = Time.get_unix_time_from_system()
		var file_path = "res://temp_audio/" + str(datetime) + ".mp3"
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		
		set_audio_ready(queue_index, file_path)
		if %AudioStreamPlayer.playing == false:
			play_next()
		
		http_request.queue_free()

func play_audio(file_path: String):
	var player = %AudioStreamPlayer
	player.stream = load_mp3(file_path)
	player.play()

func load_mp3(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var sound = AudioStreamMP3.new()
	sound.data = file.get_buffer(file.get_length())
	return sound


func _on_audio_stream_player_finished() -> void:
	play_next()

func play_next():
	if audio_queue.size() <= 0:
		return
	if audio_queue[0].ready == false:
		return
	
	var audio = audio_queue.pop_front()
	play_audio(audio.audio_file_path)
