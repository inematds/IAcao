extends Control
## TitleScreen - Tela de título do jogo
##
## Menu principal com opções de jogar, opções e sair

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var orb_glow: ColorRect = $AriaOrb/OrbGlow

var tween: Tween

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MENU)
	_start_orb_animation()
	_check_server_connection()

	# Focus first button
	play_button.grab_focus()


func _start_orb_animation() -> void:
	tween = create_tween().set_loops()
	tween.tween_property(orb_glow, "modulate:a", 0.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(orb_glow, "modulate:a", 1.0, 1.5).set_ease(Tween.EASE_IN_OUT)


func _check_server_connection() -> void:
	print("[TitleScreen] Checking server connection...")
	var response = await APIClient.health_check()

	if response.get("success", false):
		print("[TitleScreen] Server is online!")
	else:
		print("[TitleScreen] Server is offline - running in offline mode")


# ===========================================
# Button Handlers
# ===========================================

func _on_play_pressed() -> void:
	print("[TitleScreen] Play pressed")
	AudioManager.play_ui_confirm()

	# TODO: Check if logged in, show login or go to game
	# For now, go directly to game world
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")


func _on_options_pressed() -> void:
	print("[TitleScreen] Options pressed")
	AudioManager.play_ui_click()
	# TODO: Open options menu


func _on_quit_pressed() -> void:
	print("[TitleScreen] Quit pressed")
	AudioManager.play_ui_click()
	get_tree().quit()


# ===========================================
# Input
# ===========================================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
