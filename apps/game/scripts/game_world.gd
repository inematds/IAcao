extends Node2D
## GameWorld - Cena principal do mundo do jogo
##
## Gerencia o mundo, HUD, áreas e interações

@onready var player: CharacterBody2D = $Player
@onready var area_container: Node2D = $AreaContainer
@onready var energy_bar: ProgressBar = $UI/HUD/TopBar/EnergyContainer/EnergyBar
@onready var energy_label: Label = $UI/HUD/TopBar/EnergyContainer/EnergyLabel
@onready var location_label: Label = $UI/HUD/LocationLabel

# Area names for display
const AREA_NAMES := {
	"praca_central": "Praça Central",
	"escola": "Escola Comunitária",
	"casa_jogador": "Sua Casa",
	"oficina_teco": "Oficina do Teco",
	"mercado": "Mercado"
}

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("game_world")
	GameManager.set_state(GameManager.GameState.PLAYING)
	_connect_signals()
	_update_hud()
	_setup_initial_area()
	print("[GameWorld] World loaded - Vila Esperança")


func _connect_signals() -> void:
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)
	SceneManager.area_loaded.connect(_on_area_loaded)
	SceneManager.transition_started.connect(_on_transition_started)
	SceneManager.transition_completed.connect(_on_transition_completed)


func _setup_initial_area() -> void:
	# Find initial area in AreaContainer
	for child in area_container.get_children():
		if child is AreaBase:
			SceneManager.current_area = child
			SceneManager.current_area_id = child.area_id
			child.transition_requested.connect(SceneManager._on_transition_requested)
			child.on_player_enter()
			break

	GameManager.current_area = "praca_central"
	_update_location_display()


# ===========================================
# HUD Updates
# ===========================================

func _update_hud() -> void:
	_update_energy_display(GameManager.energy)
	_update_location_display()


func _update_energy_display(energy: int) -> void:
	energy_bar.value = energy
	energy_label.text = str(energy)

	# Color based on energy level
	if energy < 20:
		energy_bar.modulate = Color(1, 0.3, 0.3)
		energy_label.modulate = Color(1, 0.3, 0.3)
	elif energy < 50:
		energy_bar.modulate = Color(1, 0.8, 0.2)
		energy_label.modulate = Color(1, 0.8, 0.2)
	else:
		energy_bar.modulate = Color(1, 1, 1)
		energy_label.modulate = Color(1, 1, 1)


func _update_location_display() -> void:
	var region := GameManager.current_region
	var area := GameManager.current_area

	var region_names := {
		"vila_esperanca": "Vila Esperança"
	}

	var region_name: String = region_names.get(region, region)
	var area_name: String = AREA_NAMES.get(area, area)

	location_label.text = "%s - %s" % [region_name, area_name]


# ===========================================
# Signal Handlers
# ===========================================

func _on_energy_changed(new_energy: int) -> void:
	_update_energy_display(new_energy)


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.PAUSED:
			get_tree().paused = true
		GameManager.GameState.PLAYING:
			get_tree().paused = false


func _on_area_loaded(area_id: String) -> void:
	GameManager.current_area = area_id
	_update_location_display()


func _on_transition_started() -> void:
	# Could show loading indicator
	pass


func _on_transition_completed() -> void:
	# Could hide loading indicator
	pass


# ===========================================
# Input
# ===========================================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_toggle_pause()

	if event.is_action_pressed("aria"):
		_open_aria_panel()


func _toggle_pause() -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		GameManager.set_state(GameManager.GameState.PAUSED)
		print("[GameWorld] Game paused")
	elif GameManager.current_state == GameManager.GameState.PAUSED:
		GameManager.set_state(GameManager.GameState.PLAYING)
		print("[GameWorld] Game resumed")


func _open_aria_panel() -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	print("[GameWorld] Opening ARIA panel...")
	# TODO: Implement ARIA panel (Epic 4)
