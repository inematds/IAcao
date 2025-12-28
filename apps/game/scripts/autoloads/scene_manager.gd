extends Node
## SceneManager - Gerenciador de cenas e transições
##
## Responsável por:
## - Carregar e descarregar áreas
## - Transições suaves entre cenas
## - Manter estado de transição

# Signals
signal transition_started()
signal transition_completed()
signal area_loaded(area_id: String)

# Constants
const FADE_DURATION := 0.3
const AREAS_PATH := "res://scenes/areas/"

# State
var current_area_id: String = ""
var current_area: AreaBase = null
var is_transitioning: bool = false
var pending_spawn: String = ""

# Nodes
var transition_overlay: ColorRect
var animation_player: AnimationPlayer

# Area registry
var area_scenes: Dictionary = {
	"praca_central": "praca_central.tscn",
	"escola": "escola.tscn",
	"casa_jogador": "casa_jogador.tscn",
	"oficina_teco": "oficina_teco.tscn",
	"mercado": "mercado.tscn",
}

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_setup_transition_overlay()
	print("[SceneManager] Initialized")


func _setup_transition_overlay() -> void:
	# Create transition overlay for fades
	transition_overlay = ColorRect.new()
	transition_overlay.name = "TransitionOverlay"
	transition_overlay.color = Color.BLACK
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.modulate.a = 0.0

	# Make it cover the whole screen
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Add to a CanvasLayer so it's always on top
	var canvas := CanvasLayer.new()
	canvas.name = "TransitionLayer"
	canvas.layer = 100  # Above everything
	canvas.add_child(transition_overlay)
	add_child(canvas)

	# Create animation player
	animation_player = AnimationPlayer.new()
	animation_player.name = "TransitionAnimator"
	add_child(animation_player)

	# Create fade animations
	_create_fade_animations()


func _create_fade_animations() -> void:
	var animation_lib := AnimationLibrary.new()

	# Fade in animation (overlay becomes visible)
	var fade_in := Animation.new()
	fade_in.length = FADE_DURATION
	var track_in := fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track_in, "TransitionLayer/TransitionOverlay:modulate:a")
	fade_in.track_insert_key(track_in, 0.0, 0.0)
	fade_in.track_insert_key(track_in, FADE_DURATION, 1.0)
	animation_lib.add_animation("fade_in", fade_in)

	# Fade out animation (overlay becomes invisible)
	var fade_out := Animation.new()
	fade_out.length = FADE_DURATION
	var track_out := fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track_out, "TransitionLayer/TransitionOverlay:modulate:a")
	fade_out.track_insert_key(track_out, 0.0, 1.0)
	fade_out.track_insert_key(track_out, FADE_DURATION, 0.0)
	animation_lib.add_animation("fade_out", fade_out)

	animation_player.add_animation_library("transitions", animation_lib)


# ===========================================
# Area Transitions
# ===========================================

func change_area(area_id: String, spawn_id: String = "default") -> void:
	if is_transitioning:
		push_warning("[SceneManager] Already transitioning, ignoring request")
		return

	if not area_scenes.has(area_id):
		push_error("[SceneManager] Unknown area: %s" % area_id)
		return

	print("[SceneManager] Changing to area: %s (spawn: %s)" % [area_id, spawn_id])
	is_transitioning = true
	pending_spawn = spawn_id
	transition_started.emit()

	# Stop player movement
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("stop_movement"):
		player.stop_movement()

	# Fade to black
	animation_player.play("transitions/fade_in")
	await animation_player.animation_finished

	# Load new area
	await _load_area(area_id)

	# Fade from black
	animation_player.play("transitions/fade_out")
	await animation_player.animation_finished

	is_transitioning = false
	transition_completed.emit()

	# Resume player movement
	if player and player.has_method("resume_movement"):
		player.resume_movement()


func _load_area(area_id: String) -> void:
	var scene_path := AREAS_PATH + area_scenes[area_id]

	# Check if scene exists
	if not ResourceLoader.exists(scene_path):
		push_error("[SceneManager] Scene not found: %s" % scene_path)
		return

	# Unload current area
	if current_area:
		current_area.on_player_exit()
		current_area.queue_free()
		current_area = null

	# Load new area
	var scene := load(scene_path) as PackedScene
	if not scene:
		push_error("[SceneManager] Failed to load scene: %s" % scene_path)
		return

	current_area = scene.instantiate() as AreaBase
	if not current_area:
		push_error("[SceneManager] Scene is not an AreaBase: %s" % scene_path)
		return

	# Add to scene tree
	var game_world := get_tree().get_first_node_in_group("game_world")
	if game_world:
		# Replace existing area container content
		var area_container := game_world.get_node_or_null("AreaContainer")
		if area_container:
			for child in area_container.get_children():
				child.queue_free()
			area_container.add_child(current_area)
		else:
			game_world.add_child(current_area)
	else:
		get_tree().current_scene.add_child(current_area)

	# Connect signals
	current_area.transition_requested.connect(_on_transition_requested)

	# Spawn player
	current_area.spawn_player(pending_spawn)
	current_area.on_player_enter()

	current_area_id = area_id
	area_loaded.emit(area_id)
	print("[SceneManager] Area loaded: %s" % area_id)


func _on_transition_requested(target_area: String, target_spawn: String) -> void:
	change_area(target_area, target_spawn)


# ===========================================
# Utilities
# ===========================================

func get_current_area() -> AreaBase:
	return current_area


func is_area_loaded(area_id: String) -> bool:
	return current_area_id == area_id


func preload_area(area_id: String) -> void:
	if not area_scenes.has(area_id):
		return

	var scene_path := AREAS_PATH + area_scenes[area_id]
	ResourceLoader.load_threaded_request(scene_path)
	print("[SceneManager] Preloading area: %s" % area_id)
