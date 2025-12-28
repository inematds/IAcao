extends CanvasLayer
class_name CompetencyUI
## CompetencyUI - Interface visual para sistema de competências
##
## Responsável por:
## - Exibir competências do jogador
## - Mostrar progressão e níveis
## - Notificar level ups
## - Exibir conquistas

# Node references
@onready var main_panel: PanelContainer = $MainPanel
@onready var competencies_container: VBoxContainer = $MainPanel/VBox/CompetenciesPanel/Competencies
@onready var summary_label: Label = $MainPanel/VBox/SummaryPanel/SummaryText
@onready var achievements_container: VBoxContainer = $MainPanel/VBox/AchievementsPanel/Achievements
@onready var close_button: Button = $MainPanel/VBox/Footer/CloseButton

@onready var notification_panel: PanelContainer = $NotificationPanel
@onready var notification_icon: Label = $NotificationPanel/HBox/Icon
@onready var notification_text: Label = $NotificationPanel/HBox/VBox/Text
@onready var notification_subtext: Label = $NotificationPanel/HBox/VBox/Subtext

# State
var is_open := false
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

	# Connect to CompetencyManager if it exists
	if has_node("/root/CompetencyManager"):
		var comp_mgr := get_node("/root/CompetencyManager") as CompetencyManager
		comp_mgr.competency_level_up.connect(_on_competency_level_up)
		comp_mgr.achievement_unlocked.connect(_on_achievement_unlocked)
		comp_mgr.competency_updated.connect(_on_competency_updated)

	print("[CompetencyUI] Initialized")


func _input(event: InputEvent) -> void:
	# Toggle with Tab key (when playing)
	if event.is_action_pressed("menu"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if not is_open:
				open()
		elif is_open:
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
	_refresh_display()
	main_panel.visible = true

	# Don't change game state - just overlay


func close() -> void:
	if not is_open:
		return

	is_open = false
	main_panel.visible = false


func _on_close_pressed() -> void:
	close()


# ===========================================
# Display Refresh
# ===========================================

func _refresh_display() -> void:
	_refresh_competencies()
	_refresh_summary()
	_refresh_achievements()


func _refresh_competencies() -> void:
	# Clear existing
	for child in competencies_container.get_children():
		child.queue_free()

	# Get competency manager (may need to access differently if not autoload)
	var comp_mgr: CompetencyManager = null
	if has_node("/root/CompetencyManager"):
		comp_mgr = get_node("/root/CompetencyManager")

	if not comp_mgr:
		# Fallback: create entries from GameManager data
		_refresh_competencies_fallback()
		return

	var summary := comp_mgr.get_competency_summary()

	for comp in summary:
		var entry := _create_competency_entry(comp)
		competencies_container.add_child(entry)


func _refresh_competencies_fallback() -> void:
	# Fallback when CompetencyManager isn't available
	var competencies := GameManager.competencies

	for comp_type in competencies:
		var entry := HBoxContainer.new()
		entry.add_theme_constant_override("separation", 10)

		var name_label := Label.new()
		name_label.text = comp_type.capitalize()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		entry.add_child(name_label)

		var value_label := Label.new()
		value_label.text = str(competencies[comp_type])
		entry.add_child(value_label)

		competencies_container.add_child(entry)


func _create_competency_entry(comp: Dictionary) -> Control:
	var entry := VBoxContainer.new()
	entry.add_theme_constant_override("separation", 4)

	# Header row: icon, name, level
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)

	var icon := Label.new()
	icon.text = comp["icon"]
	icon.add_theme_font_size_override("font_size", 20)
	header.add_child(icon)

	var name_label := Label.new()
	name_label.text = comp["name"]
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", comp["color"])
	header.add_child(name_label)

	var level_label := Label.new()
	level_label.text = "Nv.%d - %s" % [comp["level"], comp["level_name"]]
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	header.add_child(level_label)

	entry.add_child(header)

	# Progress bar
	var progress_container := HBoxContainer.new()
	progress_container.add_theme_constant_override("separation", 8)

	var progress_bar := ProgressBar.new()
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	progress_bar.value = comp["progress"]
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(200, 16)
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_container.add_child(progress_bar)

	var points_label := Label.new()
	if comp["to_next"] > 0:
		points_label.text = "%d pts (+%d)" % [comp["points"], comp["to_next"]]
	else:
		points_label.text = "%d pts (MAX)" % comp["points"]
	points_label.add_theme_font_size_override("font_size", 12)
	points_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	progress_container.add_child(points_label)

	entry.add_child(progress_container)

	# Separator
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	entry.add_child(sep)

	return entry


func _refresh_summary() -> void:
	var comp_mgr: CompetencyManager = null
	if has_node("/root/CompetencyManager"):
		comp_mgr = get_node("/root/CompetencyManager")

	if not comp_mgr:
		summary_label.text = "Total de pontos: %d" % _calculate_total_points()
		return

	var total := comp_mgr.get_total_competency_points()
	var avg_level := comp_mgr.get_average_level()
	var top := comp_mgr.get_top_competencies(2)

	var text := "Total: %d pontos | Nível médio: %.1f\n" % [total, avg_level]
	text += "Destaques: "

	var highlights: Array[String] = []
	for t in top:
		highlights.append("%s %s" % [t["icon"], t["name"]])

	text += ", ".join(highlights)

	summary_label.text = text


func _calculate_total_points() -> int:
	var total := 0
	for comp_type in GameManager.competencies:
		total += GameManager.competencies[comp_type]
	return total


func _refresh_achievements() -> void:
	# Clear existing
	for child in achievements_container.get_children():
		child.queue_free()

	var comp_mgr: CompetencyManager = null
	if has_node("/root/CompetencyManager"):
		comp_mgr = get_node("/root/CompetencyManager")

	if not comp_mgr:
		var placeholder := Label.new()
		placeholder.text = "Conquistas serão exibidas aqui..."
		placeholder.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		achievements_container.add_child(placeholder)
		return

	var unlocked := comp_mgr.get_unlocked_achievements()

	if unlocked.is_empty():
		var placeholder := Label.new()
		placeholder.text = "Nenhuma conquista ainda. Continue explorando!"
		placeholder.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		achievements_container.add_child(placeholder)
		return

	for ach_id in unlocked:
		var ach := comp_mgr.get_achievement(ach_id)
		var entry := _create_achievement_entry(ach)
		achievements_container.add_child(entry)


func _create_achievement_entry(ach: Dictionary) -> Control:
	var entry := HBoxContainer.new()
	entry.add_theme_constant_override("separation", 10)

	var icon := Label.new()
	icon.text = ach.get("icon", "🏆")
	icon.add_theme_font_size_override("font_size", 24)
	entry.add_child(icon)

	var text_container := VBoxContainer.new()
	text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label := Label.new()
	name_label.text = ach.get("name", "Conquista")
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	text_container.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = ach.get("description", "")
	desc_label.add_theme_font_size_override("font_size", 11)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	text_container.add_child(desc_label)

	entry.add_child(text_container)

	return entry


# ===========================================
# Notifications
# ===========================================

func _on_competency_updated(type: String, old_value: int, new_value: int) -> void:
	# Only refresh if panel is open
	if is_open:
		_refresh_display()


func _on_competency_level_up(type: String, new_level: int) -> void:
	var comp_mgr: CompetencyManager = null
	if has_node("/root/CompetencyManager"):
		comp_mgr = get_node("/root/CompetencyManager")

	var comp_def: CompetencyManager.CompetencyDef = null
	var level_name := "Nível %d" % new_level

	if comp_mgr:
		comp_def = comp_mgr.get_competency_def(type)
		level_name = comp_mgr.get_level_name(new_level)

	var icon := "⬆️"
	var name := type.capitalize()
	if comp_def:
		icon = comp_def.icon
		name = comp_def.name_pt

	_queue_notification({
		"icon": icon,
		"title": "Level Up!",
		"subtitle": "%s → %s" % [name, level_name],
		"color": Color(0.3, 0.9, 0.5)
	})

	if is_open:
		_refresh_display()


func _on_achievement_unlocked(achievement_id: String) -> void:
	var comp_mgr: CompetencyManager = null
	if has_node("/root/CompetencyManager"):
		comp_mgr = get_node("/root/CompetencyManager")

	var ach := {}
	if comp_mgr:
		ach = comp_mgr.get_achievement(achievement_id)

	_queue_notification({
		"icon": ach.get("icon", "🏆"),
		"title": "Conquista Desbloqueada!",
		"subtitle": ach.get("name", achievement_id),
		"color": Color(1, 0.85, 0.3)
	})

	if is_open:
		_refresh_display()


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
	notification_text.text = data.get("title", "Notificação")
	notification_subtext.text = data.get("subtitle", "")

	if data.has("color"):
		notification_text.add_theme_color_override("font_color", data["color"])

	notification_panel.visible = true

	# Animate in
	var tween := create_tween()
	tween.tween_property(notification_panel, "modulate:a", 1.0, 0.3)
	tween.tween_interval(3.0)  # Show for 3 seconds
	tween.tween_property(notification_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		notification_panel.visible = false
		is_showing_notification = false
	)

	# Play sound
	AudioManager.play_ui_confirm()
