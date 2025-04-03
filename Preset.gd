class_name Preset


var name: String
var voice_provider: String
var voice_language: String
var slow: bool


func _init(
	name: String = "New preset",
	voice_provider: String = "gtts",
	voice_language: String = "en",
	slow: bool = false,
	) -> void:
	self.name = name
	self.voice_provider = voice_provider
	self.voice_language = voice_language
	self.slow = slow
