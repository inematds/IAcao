extends Node
## GameManager - Gerenciador global do jogo
##
## Responsável por:
## - Estado global do jogo
## - Transições de cena
## - Dados do jogador em memória

# Signals
signal game_state_changed(new_state: GameState)
signal energy_changed(new_energy: int)
signal competency_changed(type: String, new_level: int)

# Enums
enum GameState { MENU, PLAYING, PAUSED, DIALOGUE, CUTSCENE, LOADING }

# Constants
const MAX_ENERGY := 100
const ENERGY_REGEN_PER_MINUTE := 1

# Current state
var current_state: GameState = GameState.MENU
var is_logged_in := false

# Player data (loaded from server)
var player_data: Dictionary = {}
var competencies: Dictionary = {}
var world_flags: Dictionary = {}
var current_region := "vila_esperanca"
var current_area := "praca_central"
var energy := MAX_ENERGY

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	print("[GameManager] Initialized")
	_start_energy_regen()


func _start_energy_regen() -> void:
	var timer := Timer.new()
	timer.wait_time = 60.0  # 1 minute
	timer.autostart = true
	timer.timeout.connect(_on_energy_regen_tick)
	add_child(timer)


func _on_energy_regen_tick() -> void:
	if current_state == GameState.PLAYING:
		add_energy(ENERGY_REGEN_PER_MINUTE)


# ===========================================
# State Management
# ===========================================

func set_state(new_state: GameState) -> void:
	if current_state != new_state:
		current_state = new_state
		game_state_changed.emit(new_state)
		print("[GameManager] State changed to: ", GameState.keys()[new_state])


func is_playing() -> bool:
	return current_state == GameState.PLAYING


# ===========================================
# Energy Management
# ===========================================

func add_energy(amount: int) -> void:
	var old_energy := energy
	energy = clampi(energy + amount, 0, MAX_ENERGY)
	if energy != old_energy:
		energy_changed.emit(energy)


func use_energy(amount: int) -> bool:
	if energy >= amount:
		add_energy(-amount)
		return true
	return false


func has_energy(amount: int) -> bool:
	return energy >= amount


# ===========================================
# Competency Management
# ===========================================

func get_competency(type: String) -> int:
	return competencies.get(type, 0)


func add_competency(type: String, amount: int) -> void:
	var old_level: int = competencies.get(type, 0)
	var new_level := clampi(old_level + amount, 0, 100)
	competencies[type] = new_level
	if new_level != old_level:
		competency_changed.emit(type, new_level)
		print("[GameManager] Competency %s: %d -> %d" % [type, old_level, new_level])


# ===========================================
# World Flags
# ===========================================

func set_flag(flag_name: String, value: bool = true) -> void:
	world_flags[flag_name] = value
	print("[GameManager] Flag set: %s = %s" % [flag_name, value])


func get_flag(flag_name: String) -> bool:
	return world_flags.get(flag_name, false)


func has_flag(flag_name: String) -> bool:
	return world_flags.has(flag_name) and world_flags[flag_name]


# ===========================================
# Scene Management
# ===========================================

func change_scene(scene_path: String) -> void:
	set_state(GameState.LOADING)
	get_tree().change_scene_to_file(scene_path)


func go_to_title() -> void:
	change_scene("res://scenes/title_screen.tscn")


func go_to_game() -> void:
	change_scene("res://scenes/game_world.tscn")


# ===========================================
# Player Data
# ===========================================

func load_player_data(data: Dictionary) -> void:
	player_data = data
	competencies = data.get("competencies", {})
	world_flags = data.get("worldFlags", {})
	current_region = data.get("currentRegion", "vila_esperanca")
	energy = data.get("energy", MAX_ENERGY)
	print("[GameManager] Player data loaded")


func get_player_name() -> String:
	return player_data.get("characterName", "Jogador")


func get_player_background() -> String:
	return player_data.get("background", "explorer")
