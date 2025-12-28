extends CanvasLayer
class_name MissionUI
## MissionUI - Interface visual para sistema de missões
##
## Responsável por:
## - Exibir missões ativas e disponíveis
## - Mostrar progresso de objetivos
## - Notificar atualizações de missão
## - Exibir recompensas

# Node references
@onready var main_panel: PanelContainer = $MainPanel
@onready var tabs: TabContainer = $MainPanel/VBox/Tabs
@onready var active_list: VBoxContainer = $MainPanel/VBox/Tabs/Ativas/ScrollContainer/MissionList
@onready var available_list: VBoxContainer = $MainPanel/VBox/Tabs/Disponíveis/ScrollContainer/MissionList
@onready var completed_list: VBoxContainer = $MainPanel/VBox/Tabs/Completadas/ScrollContainer/MissionList
@onready var close_button: Button = $MainPanel/VBox/Footer/CloseButton

@onready var tracker_panel: PanelContainer = $TrackerPanel
@onready var tracker_title: Label = $TrackerPanel/VBox/Title
@onready var tracker_objectives: VBoxContainer = $TrackerPanel/VBox/Objectives

@onready var notification_panel: PanelContainer = $NotificationPanel
@onready var notification_icon: Label = $NotificationPanel/HBox/Icon
@onready var notification_title: Label = $NotificationPanel/HBox/VBox/Title
@ontml:parameter name="notification_text: Label = $NotificationPanel/HBox/VBox/Text

# State
var is_open := false
var tracked_mission_id: String = ""
var notification_queue: Array[Dictionary] = []
var is_showing_notification := false

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	main_panel.visible = false
	notification_panel.visible = false
	notification_panel.modulate.a = 0.0

	close_button.pressed.connect(_on_close_pressed)

	# Connect to MissionManager
	MissionManager.mission_started.connect(_on_mission_started)
	MissionManager.mission_updated.connect(_on_mission_updated)
	MissionManager.mission_completed.connect(_on_mission_completed)
	MissionManager.objective_completed.connect(_on_objective_completed)
	MissionManager.reward_received.connect(_on_reward_received)

	# Update tracker
	_update_tracker()

	print("[MissionUI] Initialized")


func _input(event: InputEvent) -> void:
	# Toggle with J key (Journal)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_J:
			if GameManager.current_state == GameManager.GameState.PLAYING:
				if not is_open:
					open()
				else:
					close()

	if is_open and event.is_action_pressed("cancel"):
		close()


func _process(delta: float) -> void:
	_process_notification_queue()


# ===========================================
# Panel Control
# ===========================================

func open() -> void:
	if is_open:
		return

	is_open = true
	_refresh_all_lists()
	main_panel.visible = true


func close() -> void:
	if not is_open:
		return

	is_open = false
	main_panel.visible = false


func _on_close_pressed() -> void:
	close()


# ===========================================
# List Refresh
# ===========================================

func _refresh_all_lists() -> void:
	_refresh_active_list()
	_refresh_available_list()
	_refresh_completed_list()


func _refresh_active_list() -> void:
	_clear_list(active_list)

	var missions := MissionManager.get_active_missions()

	if missions.is_empty():
		var empty := Label.new()
		empty.text = "Nenhuma missão ativa no momento."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		active_list.add_child(empty)
		return

	# Sort by order
	missions.sort_custom(func(a, b): return a.order < b.order)

	for mission in missions:
		var entry := _create_mission_entry(mission, true)
		active_list.add_child(entry)


func _refresh_available_list() -> void:
	_clear_list(available_list)

	var missions := MissionManager.get_available_missions()

	if missions.is_empty():
		var empty := Label.new()
		empty.text = "Nenhuma missão disponível. Explore mais!"
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		available_list.add_child(empty)
		return

	missions.sort_custom(func(a, b): return a.order < b.order)

	for mission in missions:
		var entry := _create_mission_entry(mission, false)
		available_list.add_child(entry)


func _refresh_completed_list() -> void:
	_clear_list(completed_list)

	var missions := MissionManager.get_completed_missions()

	if missions.is_empty():
		var empty := Label.new()
		empty.text = "Nenhuma missão completada ainda."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		completed_list.add_child(empty)
		return

	for mission in missions:
		var entry := _create_completed_entry(mission)
		completed_list.add_child(entry)


func _clear_list(list: VBoxContainer) -> void:
	for child in list.get_children():
		child.queue_free()


func _create_mission_entry(mission: MissionManager.Mission, show_objectives: bool) -> Control:
	var entry := VBoxContainer.new()
	entry.add_theme_constant_override("separation", 8)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)

	var icon := Label.new()
	icon.text = "⭐" if mission.is_main_quest else "📋"
	icon.add_theme_font_size_override("font_size", 20)
	header.add_child(icon)

	var title := Label.new()
	title.text = mission.title
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.5) if mission.is_main_quest else Color(0.9, 0.9, 0.95))
	header.add_child(title)

	if show_objectives:
		var progress := Label.new()
		progress.text = "%d%%" % int(mission.get_progress() * 100)
		progress.add_theme_font_size_override("font_size", 14)
		progress.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
		header.add_child(progress)

		var track_btn := Button.new()
		track_btn.text = "📍" if tracked_mission_id == mission.id else "○"
		track_btn.pressed.connect(func(): _track_mission(mission.id))
		header.add_child(track_btn)

	entry.add_child(header)

	# Description
	var desc := Label.new()
	desc.text = mission.description
	desc.add_theme_font_size_override("font_size", 13)
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	entry.add_child(desc)

	# Objectives (for active missions)
	if show_objectives:
		for obj in mission.objectives:
			if not obj.hidden:
				var obj_entry := _create_objective_entry(obj)
				entry.add_child(obj_entry)

	# Accept button (for available missions)
	if not show_objectives:
		var accept_btn := Button.new()
		accept_btn.text = "Aceitar Missão"
		accept_btn.pressed.connect(func(): _accept_mission(mission.id))
		entry.add_child(accept_btn)

	# Separator
	var sep := HSeparator.new()
	entry.add_child(sep)

	return entry


func _create_objective_entry(obj: MissionManager.MissionObjective) -> Control:
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override("separation", 8)

	var check := Label.new()
	check.text = "✓" if obj.is_complete else "○"
	check.add_theme_color_override("font_color", Color(0.5, 1, 0.5) if obj.is_complete else Color(0.6, 0.6, 0.7))
	entry.add_child(check)

	var text := Label.new()
	if obj.target_count > 1:
		text.text = "%s (%d/%d)" % [obj.description, obj.current_count, obj.target_count]
	else:
		text.text = obj.description
	text.add_theme_font_size_override("font_size", 13)
	text.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6) if obj.is_complete else Color(0.85, 0.85, 0.9))
	if obj.is_optional:
		text.text += " (opcional)"
	entry.add_child(text)

	return entry


func _create_completed_entry(mission: MissionManager.Mission) -> Control:
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override("separation", 10)

	var icon := Label.new()
	icon.text = "✓"
	icon.add_theme_font_size_override("font_size", 18)
	icon.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	entry.add_child(icon)

	var title := Label.new()
	title.text = mission.title
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	entry.add_child(title)

	return entry


# ===========================================
# Mission Tracking
# ===========================================

func _track_mission(mission_id: String) -> void:
	if tracked_mission_id == mission_id:
		tracked_mission_id = ""
	else:
		tracked_mission_id = mission_id

	_update_tracker()
	_refresh_active_list()


func _update_tracker() -> void:
	if tracked_mission_id == "":
		tracker_panel.visible = false
		return

	var mission := MissionManager.get_mission(tracked_mission_id)
	if not mission or mission.status != MissionManager.MissionStatus.ACTIVE:
		tracked_mission_id = ""
		tracker_panel.visible = false
		return

	tracker_panel.visible = true
	tracker_title.text = mission.title

	# Clear objectives
	for child in tracker_objectives.get_children():
		child.queue_free()

	# Add objectives
	for obj in mission.objectives:
		if not obj.hidden:
			var entry := _create_objective_entry(obj)
			tracker_objectives.add_child(entry)


func _accept_mission(mission_id: String) -> void:
	if MissionManager.start_mission(mission_id):
		_track_mission(mission_id)
		_refresh_all_lists()


# ===========================================
# Event Handlers
# ===========================================

func _on_mission_started(mission: MissionManager.Mission) -> void:
	_queue_notification({
		"icon": "📜",
		"title": "Nova Missão!",
		"text": mission.title,
		"color": Color(0.5, 0.8, 1)
	})

	if is_open:
		_refresh_all_lists()


func _on_mission_updated(mission: MissionManager.Mission, objective_id: String) -> void:
	if is_open:
		_refresh_active_list()
	_update_tracker()


func _on_mission_completed(mission: MissionManager.Mission) -> void:
	_queue_notification({
		"icon": "🎉",
		"title": "Missão Completa!",
		"text": mission.title,
		"color": Color(0.4, 1, 0.5)
	})

	if tracked_mission_id == mission.id:
		tracked_mission_id = ""
		_update_tracker()

	if is_open:
		_refresh_all_lists()


func _on_objective_completed(mission: MissionManager.Mission, objective: MissionManager.MissionObjective) -> void:
	_queue_notification({
		"icon": "✓",
		"title": "Objetivo Completo",
		"text": objective.description,
		"color": Color(0.6, 0.9, 0.6)
	})


func _on_reward_received(reward: MissionManager.MissionReward) -> void:
	_queue_notification({
		"icon": "🎁",
		"title": "Recompensa!",
		"text": reward.description,
		"color": Color(1, 0.85, 0.3)
	})


# ===========================================
# Notifications
# ===========================================

func _queue_notification(data: Dictionary) -> void:
	notification_queue.append(data)


func _process_notification_queue() -> void:
	if is_showing_notification or notification_queue.is_empty():
		return

	var notif := notification_queue.pop_front()
	_show_notification(notif)


func _show_notification(data: Dictionary) -> void:
	is_showing_notification = true

	notification_icon.text = data.get("icon", "📢")
	notification_title.text = data.get("title", "")
	notification_text.text = data.get("text", "")

	if data.has("color"):
		notification_title.add_theme_color_override("font_color", data["color"])

	notification_panel.visible = true

	var tween := create_tween()
	tween.tween_property(notification_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.5)
	tween.tween_property(notification_panel, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		notification_panel.visible = false
		is_showing_notification = false
	)

	AudioManager.play_ui_confirm()
