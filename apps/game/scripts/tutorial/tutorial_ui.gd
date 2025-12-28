extends CanvasLayer
class_name TutorialUI
## TutorialUI - Interface visual do tutorial
##
## Responsável por:
## - Exibir hints contextuais
## - Mostrar checklist de progresso
## - Animações de destaque

# Node references
@onready var hint_panel: PanelContainer = $HintPanel
@onready var hint_label: Label = $HintPanel/HBox/Label
@onready var hint_icon: Label = $HintPanel/HBox/Icon

@onready var checklist_panel: PanelContainer = $ChecklistPanel
@onready var checklist_container: VBoxContainer = $ChecklistPanel/VBox/Items

@onready var intro_panel: PanelContainer = $IntroPanel
@onready var intro_title: Label = $IntroPanel/VBox/Title
@onready var intro_text: Label = $IntroPanel/VBox/Text
@onready var intro_button: Button = $IntroPanel/VBox/Buttons/Continue
@onready var skip_button: Button = $IntroPanel/VBox/Buttons/Skip

# State
var current_hint_id := ""
var is_intro_shown := false

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	hint_panel.visible = false
	checklist_panel.visible = false
	intro_panel.visible = false

	intro_button.pressed.connect(_on_intro_continue)
	skip_button.pressed.connect(_on_intro_skip)

	# Connect to TutorialManager
	TutorialManager.hint_shown.connect(_on_hint_shown)
	TutorialManager.hint_hidden.connect(_on_hint_hidden)
	TutorialManager.tutorial_started.connect(_on_tutorial_started)
	TutorialManager.tutorial_step_completed.connect(_on_step_completed)
	TutorialManager.tutorial_completed.connect(_on_tutorial_completed)

	print("[TutorialUI] Initialized")


# ===========================================
# Hint Display
# ===========================================

func _on_hint_shown(hint_id: String) -> void:
	var step := TutorialManager.tutorial_steps.get(hint_id, null)
	if not step:
		return

	current_hint_id = hint_id
	hint_label.text = step.hint_text
	hint_icon.text = "💡"

	hint_panel.visible = true
	hint_panel.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(hint_panel, "modulate:a", 1.0, 0.3)


func _on_hint_hidden(_hint_id: String) -> void:
	if hint_panel.visible:
		var tween := create_tween()
		tween.tween_property(hint_panel, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): hint_panel.visible = false)


# ===========================================
# Intro Panel
# ===========================================

func show_intro(title: String, text: String) -> void:
	intro_title.text = title
	intro_text.text = text
	intro_panel.visible = true
	is_intro_shown = true

	intro_button.grab_focus()


func _on_intro_continue() -> void:
	intro_panel.visible = false
	is_intro_shown = false

	# Start the actual gameplay tutorial
	if TutorialManager.current_step == TutorialManager.TutorialStep.INTRO:
		TutorialManager.complete_step("intro")


func _on_intro_skip() -> void:
	intro_panel.visible = false
	is_intro_shown = false

	TutorialManager.skip_tutorial()


# ===========================================
# Checklist Display
# ===========================================

func show_checklist() -> void:
	_refresh_checklist()
	checklist_panel.visible = true


func hide_checklist() -> void:
	checklist_panel.visible = false


func toggle_checklist() -> void:
	if checklist_panel.visible:
		hide_checklist()
	else:
		show_checklist()


func _refresh_checklist() -> void:
	# Clear existing
	for child in checklist_container.get_children():
		child.queue_free()

	var checklist := TutorialManager.get_checklist()

	for item in checklist:
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)

		# Checkbox icon
		var check := Label.new()
		check.text = "✅" if item.completed else "⬜"
		check.add_theme_font_size_override("font_size", 14)
		hbox.add_child(check)

		# Title
		var title := Label.new()
		title.text = item.title
		title.add_theme_font_size_override("font_size", 14)

		if item.completed:
			title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		elif not item.required:
			title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
		else:
			title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))

		hbox.add_child(title)

		# Optional tag
		if not item.required:
			var tag := Label.new()
			tag.text = "(opcional)"
			tag.add_theme_font_size_override("font_size", 11)
			tag.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
			hbox.add_child(tag)

		checklist_container.add_child(hbox)


# ===========================================
# Tutorial Events
# ===========================================

func _on_tutorial_started(_step_id: String) -> void:
	# Show intro panel
	var step := TutorialManager.get_current_step_data()
	if step:
		show_intro(step.title, step.description)


func _on_step_completed(step_id: String) -> void:
	# Show brief completion feedback
	_show_completion_feedback(step_id)

	# Refresh checklist if visible
	if checklist_panel.visible:
		_refresh_checklist()


func _on_tutorial_completed() -> void:
	hide_checklist()
	hint_panel.visible = false

	# Show completion message
	_show_tutorial_complete()


func _show_completion_feedback(step_id: String) -> void:
	var step := TutorialManager.tutorial_steps.get(step_id, null)
	if not step:
		return

	# Flash the hint panel briefly with completion message
	hint_icon.text = "✅"
	hint_label.text = "%s - Feito!" % step.title
	hint_panel.visible = true
	hint_panel.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(hint_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): hint_panel.visible = false)


func _show_tutorial_complete() -> void:
	hint_icon.text = "🎉"
	hint_label.text = "Tutorial completo! Boa aventura!"
	hint_panel.visible = true
	hint_panel.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(hint_panel, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): hint_panel.visible = false)


# ===========================================
# Input
# ===========================================

func _input(event: InputEvent) -> void:
	# Toggle checklist with Tab
	if event.is_action_pressed("ui_focus_next") and TutorialManager.is_tutorial_active:
		toggle_checklist()
		get_viewport().set_input_as_handled()

	# Handle intro panel
	if is_intro_shown:
		if event.is_action_pressed("ui_accept"):
			_on_intro_continue()
		elif event.is_action_pressed("cancel"):
			_on_intro_skip()
