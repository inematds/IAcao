extends Node2D
## GameWorld - Cena principal do mundo do jogo
##
## Gerencia o mundo, HUD e interações

@onready var player: CharacterBody2D = $Player
@onready var energy_label: Label = $UI/HUD/EnergyBar/EnergyLabel
@onready var location_label: Label = $UI/HUD/LocationLabel

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	_connect_signals()
	_update_hud()
	print("[GameWorld] World loaded - Vila Esperança")


func _connect_signals() -> void:
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)


# ===========================================
# HUD Updates
# ===========================================

func _update_hud() -> void:
	_update_energy_display(GameManager.energy)
	_update_location_display()


func _update_energy_display(energy: int) -> void:
	energy_label.text = "%d/%d" % [energy, GameManager.MAX_ENERGY]

	# Color based on energy level
	if energy < 20:
		energy_label.modulate = Color(1, 0.3, 0.3)  # Red
	elif energy < 50:
		energy_label.modulate = Color(1, 0.8, 0.2)  # Yellow
	else:
		energy_label.modulate = Color(1, 1, 1)  # White


func _update_location_display() -> void:
	var region := GameManager.current_region
	var area := GameManager.current_area

	var region_names := {
		"vila_esperanca": "Vila Esperança"
	}

	var area_names := {
		"praca_central": "Praça Central",
		"escola": "Escola Comunitária",
		"casa_jogador": "Sua Casa",
		"oficina_teco": "Oficina do Teco",
		"mercado": "Mercado"
	}

	var region_name: String = region_names.get(region, region)
	var area_name: String = area_names.get(area, area)

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
	# TODO: Implement ARIA panel
