extends CanvasLayer
class_name DialogueUI
## DialogueUI - Interface visual para diálogos
##
## Responsável por:
## - Exibir caixa de diálogo
## - Efeito de digitação (typewriter)
## - Mostrar escolhas
## - Retrato do NPC

# Configuration
@export var typewriter_speed: float = 30.0  # Characters per second
@export var fast_typewriter_speed: float = 100.0
@export var auto_advance_delay: float = 1.5

# Node references
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var portrait_texture: TextureRect = $DialoguePanel/HBox/Portrait
@onready var portrait_placeholder: ColorRect = $DialoguePanel/HBox/PortraitPlaceholder
@onready var speaker_label: Label = $DialoguePanel/HBox/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $DialoguePanel/HBox/VBox/TextLabel
@onready var continue_indicator: Label = $DialoguePanel/HBox/VBox/ContinueIndicator
@onready var choices_container: VBoxContainer = $ChoicesPanel/ChoicesContainer
@onready var choices_panel: PanelContainer = $ChoicesPanel

# State
var is_typing := false
var is_waiting_for_input := false
var is_showing_choices := false
var current_text := ""
var displayed_chars := 0
var typewriter_timer := 0.0
var current_speed: float = 0.0
var continue_blink_timer := 0.0

# Choice buttons
var choice_buttons: Array[Button] = []
var selected_choice_index := 0

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	# Hide initially
	dialogue_panel.visible = false
	choices_panel.visible = false

	# Connect to DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_started.connect(_on_line_started)
	DialogueManager.choices_presented.connect(_on_choices_presented)

	print("[DialogueUI] Initialized")


func _process(delta: float) -> void:
	if is_typing:
		_process_typewriter(delta)

	if is_waiting_for_input:
		_process_continue_indicator(delta)


func _input(event: InputEvent) -> void:
	if not dialogue_panel.visible:
		return

	if is_showing_choices:
		_handle_choice_input(event)
	else:
		_handle_dialogue_input(event)


# ===========================================
# Input Handling
# ===========================================

func _handle_dialogue_input(event: InputEvent) -> void:
	var advance := event.is_action_pressed("interact") or \
				   event.is_action_pressed("ui_accept") or \
				   (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)

	if advance:
		if is_typing:
			# Skip to full text
			_complete_typewriter()
		elif is_waiting_for_input:
			# Advance dialogue
			is_waiting_for_input = false
			continue_indicator.visible = false
			DialogueManager.advance_dialogue()


func _handle_choice_input(event: InputEvent) -> void:
	# Keyboard navigation
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		_select_choice(selected_choice_index - 1)
	elif event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		_select_choice(selected_choice_index + 1)
	elif event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		_confirm_choice()


# ===========================================
# Dialogue Display
# ===========================================

func _on_dialogue_started(dialogue_id: String, npc_name: String) -> void:
	dialogue_panel.visible = true
	choices_panel.visible = false
	speaker_label.text = npc_name
	text_label.text = ""
	continue_indicator.visible = false


func _on_dialogue_ended(dialogue_id: String) -> void:
	dialogue_panel.visible = false
	choices_panel.visible = false
	is_typing = false
	is_waiting_for_input = false
	is_showing_choices = false


func _on_line_started(line: DialogueManager.DialogueLine) -> void:
	# Update speaker
	speaker_label.text = line.speaker

	# Update portrait
	_update_portrait(line.portrait, line.emotion)

	# Start typewriter effect
	_start_typewriter(line.text)

	# Hide choices initially
	choices_panel.visible = false
	is_showing_choices = false


func _update_portrait(portrait_id: String, emotion: String) -> void:
	if portrait_id == "":
		portrait_texture.visible = false
		portrait_placeholder.visible = true
		return

	var portrait_path := "res://assets/portraits/%s_%s.png" % [portrait_id, emotion]

	if not ResourceLoader.exists(portrait_path):
		portrait_path = "res://assets/portraits/%s_neutral.png" % portrait_id

	if ResourceLoader.exists(portrait_path):
		portrait_texture.texture = load(portrait_path)
		portrait_texture.visible = true
		portrait_placeholder.visible = false
	else:
		portrait_texture.visible = false
		portrait_placeholder.visible = true
		# Set placeholder color based on portrait_id hash
		var hash_val := portrait_id.hash()
		portrait_placeholder.color = Color.from_hsv(
			(hash_val % 360) / 360.0,
			0.5,
			0.7
		)


# ===========================================
# Typewriter Effect
# ===========================================

func _start_typewriter(text: String) -> void:
	current_text = text
	displayed_chars = 0
	typewriter_timer = 0.0
	current_speed = typewriter_speed
	is_typing = true
	is_waiting_for_input = false
	continue_indicator.visible = false

	text_label.text = ""


func _process_typewriter(delta: float) -> void:
	typewriter_timer += delta * current_speed

	var chars_to_show := int(typewriter_timer)
	if chars_to_show > displayed_chars:
		displayed_chars = min(chars_to_show, current_text.length())
		text_label.text = current_text.substr(0, displayed_chars)

		# Play typing sound occasionally
		if displayed_chars % 3 == 0:
			AudioManager.play_ui_click()

	if displayed_chars >= current_text.length():
		_complete_typewriter()


func _complete_typewriter() -> void:
	is_typing = false
	displayed_chars = current_text.length()
	text_label.text = current_text

	# Check if this line has choices
	var line_data := DialogueManager._get_line_data(DialogueManager.current_line_id)
	var choices: Array = line_data.get("choices", [])

	if choices.size() > 0:
		# Choices will be shown by _on_choices_presented
		pass
	else:
		# Show continue indicator
		is_waiting_for_input = true
		continue_indicator.visible = true
		continue_blink_timer = 0.0


func _process_continue_indicator(delta: float) -> void:
	continue_blink_timer += delta * 3.0
	continue_indicator.modulate.a = 0.5 + sin(continue_blink_timer) * 0.5


# ===========================================
# Choice System
# ===========================================

func _on_choices_presented(choices: Array[DialogueManager.DialogueChoice]) -> void:
	# Wait for typewriter to finish
	if is_typing:
		await get_tree().create_timer(0.1).timeout
		_on_choices_presented(choices)
		return

	# Clear existing buttons
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

	# Create choice buttons
	for i in range(choices.size()):
		var choice := choices[i]
		var button := Button.new()
		button.text = "%d. %s" % [i + 1, choice.text]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 16)

		# Style
		button.custom_minimum_size = Vector2(500, 40)

		# Connect signals
		var index := i  # Capture for closure
		button.pressed.connect(func(): _on_choice_button_pressed(index))
		button.mouse_entered.connect(func(): _select_choice(index))

		choices_container.add_child(button)
		choice_buttons.append(button)

	# Show choices panel
	choices_panel.visible = true
	is_showing_choices = true
	selected_choice_index = 0
	_update_choice_selection()


func _select_choice(index: int) -> void:
	if choice_buttons.is_empty():
		return

	selected_choice_index = clamp(index, 0, choice_buttons.size() - 1)
	_update_choice_selection()


func _update_choice_selection() -> void:
	for i in range(choice_buttons.size()):
		var button := choice_buttons[i]
		if i == selected_choice_index:
			button.add_theme_color_override("font_color", Color(1, 1, 0.8))
			button.grab_focus()
		else:
			button.add_theme_color_override("font_color", Color(1, 1, 1))


func _on_choice_button_pressed(index: int) -> void:
	_select_choice(index)
	_confirm_choice()


func _confirm_choice() -> void:
	if not is_showing_choices:
		return

	is_showing_choices = false
	choices_panel.visible = false

	AudioManager.play_ui_confirm()
	DialogueManager.select_choice(selected_choice_index)
