extends CanvasLayer
class_name SaveLoadUI
## SaveLoadUI - Interface para salvar e carregar jogos
##
## Responsável por:
## - Exibir slots de save
## - Permitir salvar/carregar
## - Mostrar informações do save
## - Confirmar sobrescrever saves

# Mode
enum Mode { SAVE, LOAD }

# Node references
@onready var main_panel: PanelContainer = $MainPanel
@onready var title_label: Label = $MainPanel/VBox/Header/Title
@onready var slots_container: VBoxContainer = $MainPanel/VBox/SlotsPanel/Slots
@onready var close_button: Button = $MainPanel/VBox/Footer/CloseButton

@onready var confirm_panel: PanelContainer = $ConfirmPanel
@onready var confirm_text: Label = $ConfirmPanel/VBox/Text
@onready var confirm_yes: Button = $ConfirmPanel/VBox/Buttons/Yes
@onready var confirm_no: Button = $ConfirmPanel/VBox/Buttons/No

@onready var notification_label: Label = $NotificationLabel

# State
var is_open := false
var current_mode: Mode = Mode.SAVE
var selected_slot := 1
var pending_action: Callable

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	main_panel.visible = false
	confirm_panel.visible = false
	notification_label.visible = false

	close_button.pressed.connect(_on_close_pressed)
	confirm_yes.pressed.connect(_on_confirm_yes)
	confirm_no.pressed.connect(_on_confirm_no)

	# Connect to SaveManager
	SaveManager.save_completed.connect(_on_save_completed)
	SaveManager.load_completed.connect(_on_load_completed)

	print("[SaveLoadUI] Initialized")


func _input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("cancel"):
		if confirm_panel.visible:
			_on_confirm_no()
		else:
			close()


# ===========================================
# Panel Control
# ===========================================

func open_save() -> void:
	current_mode = Mode.SAVE
	title_label.text = "💾 Salvar Jogo"
	_open()


func open_load() -> void:
	current_mode = Mode.LOAD
	title_label.text = "📂 Carregar Jogo"
	_open()


func _open() -> void:
	if is_open:
		return

	is_open = true
	_refresh_slots()
	main_panel.visible = true
	confirm_panel.visible = false

	GameManager.set_state(GameManager.GameState.PAUSED)


func close() -> void:
	if not is_open:
		return

	is_open = false
	main_panel.visible = false
	confirm_panel.visible = false

	GameManager.set_state(GameManager.GameState.PLAYING)


func _on_close_pressed() -> void:
	close()


# ===========================================
# Slots Display
# ===========================================

func _refresh_slots() -> void:
	# Clear existing
	for child in slots_container.get_children():
		child.queue_free()

	var slots := SaveManager.get_save_slots()

	for slot_info in slots:
		var entry := _create_slot_entry(slot_info)
		slots_container.add_child(entry)


func _create_slot_entry(slot_info: Dictionary) -> Control:
	var entry := PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 80)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	entry.add_child(hbox)

	var slot_num := slot_info.get("slot", 1)

	# Slot number
	var num_label := Label.new()
	num_label.text = "Slot %d" % slot_num
	num_label.add_theme_font_size_override("font_size", 18)
	num_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	num_label.custom_minimum_size = Vector2(80, 0)
	hbox.add_child(num_label)

	# Info container
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if slot_info.get("empty", false):
		var empty_label := Label.new()
		empty_label.text = "--- Vazio ---"
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		info.add_child(empty_label)
	else:
		var name_label := Label.new()
		name_label.text = slot_info.get("characterName", "Jogador")
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
		info.add_child(name_label)

		var details_label := Label.new()
		var play_time := slot_info.get("playTime", 0)
		var region := slot_info.get("region", "vila_esperanca")
		details_label.text = "%s | %dh %dm" % [region.replace("_", " ").capitalize(), play_time / 60, play_time % 60]
		details_label.add_theme_font_size_override("font_size", 13)
		details_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		info.add_child(details_label)

		var date_label := Label.new()
		date_label.text = slot_info.get("lastSaved", "")
		date_label.add_theme_font_size_override("font_size", 11)
		date_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
		info.add_child(date_label)

	hbox.add_child(info)

	# Action button
	var action_btn := Button.new()
	if current_mode == Mode.SAVE:
		action_btn.text = "Salvar"
		action_btn.pressed.connect(func(): _on_save_slot(slot_num, not slot_info.get("empty", false)))
	else:
		if slot_info.get("empty", false):
			action_btn.text = "Vazio"
			action_btn.disabled = true
		else:
			action_btn.text = "Carregar"
			action_btn.pressed.connect(func(): _on_load_slot(slot_num))

	action_btn.custom_minimum_size = Vector2(100, 0)
	hbox.add_child(action_btn)

	return entry


# ===========================================
# Save/Load Actions
# ===========================================

func _on_save_slot(slot: int, has_existing: bool) -> void:
	selected_slot = slot

	if has_existing:
		# Confirm overwrite
		_show_confirm("Sobrescrever o save existente no Slot %d?" % slot, func():
			SaveManager.save_game(slot)
		)
	else:
		SaveManager.save_game(slot)


func _on_load_slot(slot: int) -> void:
	selected_slot = slot

	_show_confirm("Carregar o jogo do Slot %d?\nO progresso não salvo será perdido." % slot, func():
		SaveManager.load_game(slot)
		close()
		# Transition to game
		SceneManager.change_area(GameManager.current_area)
	)


func _on_save_completed(success: bool) -> void:
	if success:
		_show_notification("Jogo salvo com sucesso!")
		_refresh_slots()
	else:
		_show_notification("Erro ao salvar o jogo!")


func _on_load_completed(success: bool) -> void:
	if success:
		_show_notification("Jogo carregado!")
	else:
		_show_notification("Erro ao carregar o jogo!")


# ===========================================
# Confirmation Dialog
# ===========================================

func _show_confirm(text: String, action: Callable) -> void:
	confirm_text.text = text
	pending_action = action
	confirm_panel.visible = true
	confirm_yes.grab_focus()


func _on_confirm_yes() -> void:
	confirm_panel.visible = false
	if pending_action:
		pending_action.call()


func _on_confirm_no() -> void:
	confirm_panel.visible = false
	pending_action = Callable()


# ===========================================
# Notification
# ===========================================

func _show_notification(text: String) -> void:
	notification_label.text = text
	notification_label.visible = true
	notification_label.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(notification_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): notification_label.visible = false)
