extends Node
## AudioManager - Gerenciador de áudio
##
## Responsável por:
## - Música de fundo
## - Efeitos sonoros
## - Controle de volume

# Audio buses
const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

# Players
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8

# State
var current_music: String = ""
var music_volume := 0.8
var sfx_volume := 1.0
var master_volume := 1.0

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_setup_audio_players()
	_load_settings()
	print("[AudioManager] Initialized")


func _setup_audio_players() -> void:
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = BUS_MUSIC
	add_child(music_player)

	# SFX players pool
	for i in range(MAX_SFX_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		sfx_players.append(player)


func _load_settings() -> void:
	var settings := SaveManager.load_settings()
	set_master_volume(settings.get("masterVolume", 1.0))
	set_music_volume(settings.get("musicVolume", 0.8))
	set_sfx_volume(settings.get("sfxVolume", 1.0))


# ===========================================
# Music
# ===========================================

func play_music(path: String, fade_duration: float = 1.0) -> void:
	if current_music == path:
		return

	if current_music != "":
		await _fade_out_music(fade_duration)

	var stream := load(path) as AudioStream
	if stream == null:
		push_error("[AudioManager] Failed to load music: ", path)
		return

	current_music = path
	music_player.stream = stream
	music_player.volume_db = -80
	music_player.play()

	await _fade_in_music(fade_duration)

	print("[AudioManager] Playing music: ", path)


func stop_music(fade_duration: float = 1.0) -> void:
	if current_music == "":
		return

	await _fade_out_music(fade_duration)
	music_player.stop()
	current_music = ""


func _fade_in_music(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), duration)
	await tween.finished


func _fade_out_music(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -80, duration)
	await tween.finished


# ===========================================
# Sound Effects
# ===========================================

func play_sfx(path: String, pitch_variation: float = 0.0) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		push_error("[AudioManager] Failed to load SFX: ", path)
		return

	var player := _get_available_sfx_player()
	if player == null:
		push_warning("[AudioManager] No available SFX player")
		return

	player.stream = stream
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	player.play()


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return null


# UI sounds (common)
func play_ui_click() -> void:
	# Placeholder - add actual sound file path
	pass


func play_ui_hover() -> void:
	# Placeholder
	pass


func play_ui_confirm() -> void:
	# Placeholder
	pass


func play_ui_cancel() -> void:
	# Placeholder
	pass


# ===========================================
# Volume Control
# ===========================================

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(BUS_MASTER),
		linear_to_db(master_volume)
	)


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	if music_player.playing:
		music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(BUS_SFX),
		linear_to_db(sfx_volume)
	)


func get_volumes() -> Dictionary:
	return {
		"master": master_volume,
		"music": music_volume,
		"sfx": sfx_volume
	}
