extends Node
## SaveManager - Gerenciador de saves locais
##
## Responsável por:
## - Salvar/carregar dados localmente
## - Sincronizar com servidor quando online
## - Cache offline
## - Auto-save

# Signals
signal save_started()
signal save_completed(success: bool)
signal load_started()
signal load_completed(success: bool)
signal auto_save_triggered()

# Constants
const SAVE_PATH := "user://saves/"
const SETTINGS_PATH := "user://settings.json"
const AUTO_SAVE_INTERVAL := 60.0  # 1 minute
const MAX_SAVE_SLOTS := 3

# State
var current_slot := 1
var is_saving := false
var is_loading := false
var play_time_seconds := 0.0
var last_save_time := 0

# Auto-save
var auto_save_timer: Timer
var auto_save_enabled := true

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_ensure_save_directory()
	_setup_auto_save()
	print("[SaveManager] Initialized")


func _process(delta: float) -> void:
	# Track play time when playing
	if GameManager.current_state == GameManager.GameState.PLAYING:
		play_time_seconds += delta


func _ensure_save_directory() -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")


func _setup_auto_save() -> void:
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	auto_save_timer.autostart = false
	auto_save_timer.timeout.connect(_on_auto_save)
	add_child(auto_save_timer)


func _on_auto_save() -> void:
	if auto_save_enabled and GameManager.current_state == GameManager.GameState.PLAYING:
		auto_save_triggered.emit()
		save_game(current_slot)
		print("[SaveManager] Auto-save triggered")


func start_auto_save() -> void:
	if not auto_save_timer.is_stopped():
		return
	auto_save_timer.start()
	print("[SaveManager] Auto-save started (every %ds)" % int(AUTO_SAVE_INTERVAL))


func stop_auto_save() -> void:
	auto_save_timer.stop()


# ===========================================
# Full Game Save/Load
# ===========================================

func save_game(slot: int = -1) -> bool:
	if is_saving:
		return false

	if slot == -1:
		slot = current_slot

	is_saving = true
	save_started.emit()

	var save_data := _collect_save_data()
	var success := save_local(slot, save_data)

	# Also sync to cloud if logged in
	if APIClient.is_authenticated:
		_sync_to_cloud(save_data)

	is_saving = false
	current_slot = slot
	last_save_time = int(Time.get_unix_time_from_system())

	save_completed.emit(success)
	return success


func load_game(slot: int) -> bool:
	if is_loading:
		return false

	is_loading = true
	load_started.emit()

	var save_data := load_local(slot)

	if save_data.is_empty():
		is_loading = false
		load_completed.emit(false)
		return false

	_apply_save_data(save_data)

	current_slot = slot
	is_loading = false
	load_completed.emit(true)

	# Start auto-save
	start_auto_save()

	return true


func _collect_save_data() -> Dictionary:
	var now := Time.get_datetime_string_from_system()

	var data := {
		"version": "1.0",
		"lastSaved": now,
		"playTimeMinutes": int(play_time_seconds / 60.0),

		# Player info
		"characterName": GameManager.player_name,
		"currentRegion": GameManager.current_region,
		"currentArea": GameManager.current_area,
		"energy": GameManager.energy,

		# Competencies
		"competencies": GameManager.competencies.duplicate(),

		# World state
		"worldFlags": GameManager.world_flags.duplicate(),

		# NPC Memory
		"npcMemory": DialogueManager.save_npc_memory(),

		# Missions
		"missions": MissionManager.save_data(),

		# ARIA history
		"ariaHistory": ARIAManager.save_data()
	}

	return data


func _apply_save_data(data: Dictionary) -> void:
	# Player info
	GameManager.player_name = data.get("characterName", "Jogador")
	GameManager.current_region = data.get("currentRegion", "vila_esperanca")
	GameManager.current_area = data.get("currentArea", "praca_central")
	GameManager.energy = data.get("energy", GameManager.MAX_ENERGY)

	# Play time
	play_time_seconds = data.get("playTimeMinutes", 0) * 60.0

	# Competencies
	GameManager.competencies = data.get("competencies", {})

	# World state
	GameManager.world_flags = data.get("worldFlags", {})

	# NPC Memory
	var npc_data: Dictionary = data.get("npcMemory", {})
	DialogueManager.load_npc_memory(npc_data)

	# Missions
	var mission_data: Dictionary = data.get("missions", {})
	MissionManager.load_data(mission_data)

	# ARIA history
	var aria_data: Dictionary = data.get("ariaHistory", {})
	ARIAManager.load_data(aria_data)

	print("[SaveManager] Save data applied")


func _sync_to_cloud(data: Dictionary) -> void:
	# Fire and forget cloud sync
	APIClient.save_game(data)
	print("[SaveManager] Syncing to cloud...")


func load_from_cloud() -> void:
	if not APIClient.is_authenticated:
		return

	var response := await APIClient.load_game()
	if response.get("success", false):
		var cloud_data: Dictionary = response.get("data", {})
		if not cloud_data.is_empty():
			_apply_save_data(cloud_data)
			print("[SaveManager] Loaded from cloud")


# ===========================================
# Quick Save/Load
# ===========================================

func quick_save() -> bool:
	return save_game(current_slot)


func quick_load() -> bool:
	return load_game(current_slot)


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
