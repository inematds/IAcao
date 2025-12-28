extends Node
## SaveManager - Gerenciador de saves locais
##
## Responsável por:
## - Salvar/carregar dados localmente
## - Sincronizar com servidor quando online
## - Cache offline

# Constants
const SAVE_PATH := "user://saves/"
const SETTINGS_PATH := "user://settings.json"

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_ensure_save_directory()
	print("[SaveManager] Initialized")


func _ensure_save_directory() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")


# ===========================================
# Local Save/Load
# ===========================================

func save_local(slot: int, data: Dictionary) -> bool:
	var file_path := SAVE_PATH + "slot_%d.json" % slot
	var file := FileAccess.open(file_path, FileAccess.WRITE)

	if file == null:
		push_error("[SaveManager] Failed to open file for writing: ", file_path)
		return false

	var json_str := JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()

	print("[SaveManager] Saved to slot %d" % slot)
	return true


func load_local(slot: int) -> Dictionary:
	var file_path := SAVE_PATH + "slot_%d.json" % slot

	if not FileAccess.file_exists(file_path):
		print("[SaveManager] No save file found in slot %d" % slot)
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Failed to open file for reading: ", file_path)
		return {}

	var json_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_str)

	if error != OK:
		push_error("[SaveManager] Failed to parse save file")
		return {}

	print("[SaveManager] Loaded from slot %d" % slot)
	return json.data


func delete_local(slot: int) -> bool:
	var file_path := SAVE_PATH + "slot_%d.json" % slot

	if not FileAccess.file_exists(file_path):
		return true

	var dir := DirAccess.open(SAVE_PATH)
	if dir:
		var error := dir.remove("slot_%d.json" % slot)
		if error == OK:
			print("[SaveManager] Deleted slot %d" % slot)
			return true

	push_error("[SaveManager] Failed to delete slot %d" % slot)
	return false


func get_save_slots() -> Array[Dictionary]:
	var slots: Array[Dictionary] = []

	for i in range(1, 4):  # 3 slots
		var data := load_local(i)
		if data.size() > 0:
			slots.append({
				"slot": i,
				"characterName": data.get("characterName", "Unknown"),
				"playTime": data.get("playTimeMinutes", 0),
				"lastSaved": data.get("lastSaved", ""),
				"region": data.get("currentRegion", "")
			})
		else:
			slots.append({
				"slot": i,
				"empty": true
			})

	return slots


# ===========================================
# Settings
# ===========================================

func save_settings(settings: Dictionary) -> bool:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)

	if file == null:
		push_error("[SaveManager] Failed to save settings")
		return false

	var json_str := JSON.stringify(settings, "\t")
	file.store_string(json_str)
	file.close()

	print("[SaveManager] Settings saved")
	return true


func load_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return get_default_settings()

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return get_default_settings()

	var json_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_str)

	if error != OK:
		return get_default_settings()

	return json.data


func get_default_settings() -> Dictionary:
	return {
		"masterVolume": 1.0,
		"musicVolume": 0.8,
		"sfxVolume": 1.0,
		"fullscreen": false,
		"language": "pt_BR"
	}


# ===========================================
# Secure Data (for auth tokens, etc.)
# ===========================================

const SECURE_PATH := "user://secure/"

func _ensure_secure_directory() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("secure"):
		dir.make_dir("secure")


func save_secure_data(key: String, data: Dictionary) -> bool:
	_ensure_secure_directory()
	var file_path := SECURE_PATH + key + ".dat"
	var file := FileAccess.open(file_path, FileAccess.WRITE)

	if file == null:
		push_error("[SaveManager] Failed to save secure data: ", key)
		return false

	# Simple obfuscation (not true encryption, but prevents casual inspection)
	var json_str := JSON.stringify(data)
	var encoded := Marshalls.utf8_to_base64(json_str)
	file.store_string(encoded)
	file.close()

	return true


func load_secure_data(key: String) -> Dictionary:
	var file_path := SECURE_PATH + key + ".dat"

	if not FileAccess.file_exists(file_path):
		return {}

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}

	var encoded := file.get_as_text()
	file.close()

	var json_str := Marshalls.base64_to_utf8(encoded)
	if json_str == "":
		return {}

	var json := JSON.new()
	var error := json.parse(json_str)

	if error != OK:
		return {}

	return json.data


func delete_secure_data(key: String) -> bool:
	var file_path := SECURE_PATH + key + ".dat"

	if not FileAccess.file_exists(file_path):
		return true

	var dir := DirAccess.open(SECURE_PATH)
	if dir:
		var error := dir.remove(key + ".dat")
		return error == OK

	return false
