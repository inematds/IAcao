extends CanvasLayer
class_name ARIAUI
## ARIAUI - Interface visual para interação com ARIA
##
## Responsável por:
## - Exibir menu de ações da ARIA
## - Mostrar custos de energia
## - Campo de contexto adicional
## - Exibir respostas da IA

# Configuration
@export var typing_speed: float = 40.0  # Characters per second

# Node references
@onready var main_panel: PanelContainer = $MainPanel
@onready var header_label: Label = $MainPanel/VBox/Header/Title
@onready var energy_label: Label = $MainPanel/VBox/Header/EnergyInfo
@onready var actions_container: VBoxContainer = $MainPanel/VBox/ActionsPanel/Actions
@onready var context_input: LineEdit = $MainPanel/VBox/ContextPanel/ContextInput
@onready var response_panel: PanelContainer = $MainPanel/VBox/ResponsePanel
@onready var response_label: RichTextLabel = $MainPanel/VBox/ResponsePanel/ResponseText
@onready var close_button: Button = $MainPanel/VBox/Footer/CloseButton
@onready var loading_label: Label = $MainPanel/VBox/ResponsePanel/LoadingLabel

# State
var action_buttons: Array[Button] = []
var selected_action_index := 0
var is_typing_response := false
var current_response := ""
var displayed_chars := 0
var typing_timer := 0.0

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	# Hide initially
	main_panel.visible = false

	# Connect to ARIAManager
	ARIAManager.aria_opened.connect(_on_aria_opened)
	ARIAManager.aria_closed.connect(_on_aria_closed)
	ARIAManager.action_started.connect(_on_action_started)
	ARIAManager.action_completed.connect(_on_action_completed)
	ARIAManager.action_failed.connect(_on_action_failed)
	ARIAManager.energy_insufficient.connect(_on_energy_insufficient)

	# Connect UI elements
	close_button.pressed.connect(_on_close_pressed)
	context_input.text_submitted.connect(_on_context_submitted)

	# Update energy display
	GameManager.energy_changed.connect(_update_energy_display)

	print("[ARIAUI] Initialized")


func _process(delta: float) -> void:
	if is_typing_response:
		_process_typing(delta)


func _input(event: InputEvent) -> void:
	if not main_panel.visible:
		return

	# Navigation
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_select_action(selected_action_index - 1)
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_select_action(selected_action_index + 1)
	elif event.is_action_pressed("cancel"):
		ARIAManager.close_aria()
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if is_typing_response:
			_complete_typing()
		elif not ARIAManager.is_processing:
			_confirm_action()


# ===========================================
# ARIA Events
# ===========================================

func _on_aria_opened() -> void:
	main_panel.visible = true
	response_panel.visible = false
	loading_label.visible = false

	_update_energy_display(GameManager.energy)
	_create_action_buttons()
	_select_action(0)

	context_input.text = ""
	context_input.grab_focus()


func _on_aria_closed() -> void:
	main_panel.visible = false
	is_typing_response = false


func _on_action_started(action: ARIAManager.ARIAAction) -> void:
	# Show loading state
	response_panel.visible = true
	response_label.text = ""
	loading_label.visible = true
	loading_label.text = "ARIA está %s..." % _get_action_verb(action.type)

	# Disable action buttons
	for button in action_buttons:
		button.disabled = true

	context_input.editable = false


func _on_action_completed(action: ARIAManager.ARIAAction, response: String) -> void:
	loading_label.visible = false

	# Start typing effect
	_start_typing(response)

	# Re-enable buttons
	for button in action_buttons:
		button.disabled = false

	context_input.editable = true

	# Update energy display
	_update_energy_display(GameManager.energy)
	_update_action_buttons()

	# Track competency
	ARIAManager.record_aria_usage(action.type)


func _on_action_failed(action: ARIAManager.ARIAAction, error: String) -> void:
	loading_label.visible = false
	response_panel.visible = true
	response_label.text = "[color=#ff6666]Erro: %s[/color]\n\nTente novamente em alguns instantes." % error

	# Re-enable buttons
	for button in action_buttons:
		button.disabled = false

	context_input.editable = true

	# Refund energy on failure
	GameManager.add_energy(action.energy_cost)
	_update_energy_display(GameManager.energy)
	_update_action_buttons()


func _on_energy_insufficient(required: int, available: int) -> void:
	response_panel.visible = true
	response_label.text = "[color=#ffcc66]Energia insuficiente![/color]\n\nVocê precisa de %d de energia, mas tem apenas %d.\n\nDescanse um pouco ou complete missões para recuperar energia." % [required, available]


# ===========================================
# Action Buttons
# ===========================================

func _create_action_buttons() -> void:
	# Clear existing
	for button in action_buttons:
		button.queue_free()
	action_buttons.clear()

	# Create buttons for each action
	for i in range(ARIAManager.actions.size()):
		var action := ARIAManager.actions[i]
		var button := Button.new()

		_update_button_text(button, action)

		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 16)
		button.custom_minimum_size = Vector2(0, 50)

		# Connect signals
		var index := i
		button.pressed.connect(func(): _on_action_button_pressed(index))
		button.mouse_entered.connect(func(): _select_action(index))

		actions_container.add_child(button)
		action_buttons.append(button)

	_update_action_buttons()


func _update_button_text(button: Button, action: ARIAManager.ARIAAction) -> void:
	var can_afford := GameManager.has_energy(action.energy_cost)
	var cost_color := "white" if can_afford else "#888888"

	button.text = "%s %s - %d⚡" % [action.icon, action.name, action.energy_cost]

	if not can_afford:
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5, 1)
	else:
		button.disabled = false
		button.modulate = Color(1, 1, 1, 1)


func _update_action_buttons() -> void:
	for i in range(action_buttons.size()):
		var button := action_buttons[i]
		var action := ARIAManager.actions[i]
		_update_button_text(button, action)


func _select_action(index: int) -> void:
	if action_buttons.is_empty():
		return

	selected_action_index = clamp(index, 0, action_buttons.size() - 1)

	for i in range(action_buttons.size()):
		var button := action_buttons[i]
		if i == selected_action_index:
			button.add_theme_color_override("font_color", Color(1, 1, 0.8))
			button.grab_focus()

			# Show action description
			var action := ARIAManager.actions[i]
			_show_action_description(action)
		else:
			button.remove_theme_color_override("font_color")


func _show_action_description(action: ARIAManager.ARIAAction) -> void:
	if not response_panel.visible or ARIAManager.is_processing:
		response_panel.visible = true
		response_label.text = "[color=#aaaaff]%s[/color]\n\n%s\n\n[color=#888888]Custo: %d de energia[/color]" % [
			action.name,
			action.description,
			action.energy_cost
		]


func _on_action_button_pressed(index: int) -> void:
	_select_action(index)
	_confirm_action()


func _confirm_action() -> void:
	if selected_action_index >= ARIAManager.actions.size():
		return

	var action := ARIAManager.actions[selected_action_index]

	if not ARIAManager.can_perform_action(action):
		return

	var context := context_input.text.strip_edges()
	ARIAManager.perform_action(action, context)


# ===========================================
# Typing Effect
# ===========================================

func _start_typing(text: String) -> void:
	current_response = text
	displayed_chars = 0
	typing_timer = 0.0
	is_typing_response = true
	response_label.text = ""


func _process_typing(delta: float) -> void:
	typing_timer += delta * typing_speed

	var chars_to_show := int(typing_timer)
	if chars_to_show > displayed_chars:
		displayed_chars = min(chars_to_show, current_response.length())
		response_label.text = current_response.substr(0, displayed_chars)

		# Sound effect occasionally
		if displayed_chars % 5 == 0:
			AudioManager.play_ui_click()

	if displayed_chars >= current_response.length():
		_complete_typing()


func _complete_typing() -> void:
	is_typing_response = false
	displayed_chars = current_response.length()
	response_label.text = current_response


# ===========================================
# UI Updates
# ===========================================

func _update_energy_display(energy: int) -> void:
	energy_label.text = "⚡ %d/%d" % [energy, GameManager.MAX_ENERGY]


func _get_action_verb(type: ARIAManager.ActionType) -> String:
	match type:
		ARIAManager.ActionType.ANALYZE:
			return "analisando"
		ARIAManager.ActionType.SUGGEST:
			return "pensando em sugestões"
		ARIAManager.ActionType.SIMULATE:
			return "simulando cenários"
		ARIAManager.ActionType.IMPROVE:
			return "avaliando melhorias"
		_:
			return "processando"


func _on_close_pressed() -> void:
	ARIAManager.close_aria()


func _on_context_submitted(text: String) -> void:
	# Pressing enter in context field confirms action
	_confirm_action()
