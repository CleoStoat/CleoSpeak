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

func _to_string():
	var preset_dict = {"name": name, "voice_provider": voice_provider, "voice_language": voice_language, "slow": slow}
	return str(preset_dict)

static func serialize(presets: Array[Preset]) -> String:
	var dict_array = []
	for preset in presets:
		var inst_dict = inst_to_dict(preset)
		inst_dict.erase("@path")
		inst_dict.erase("@subpath")
		dict_array.append(inst_dict)
	return JSON.stringify(dict_array, "  ")
