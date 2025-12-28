extends CanvasLayer
class_name DebugConsole
## DebugConsole - Console de debug para desenvolvimento
##
## Comandos disponíveis:
## - help: Lista comandos
## - energy [valor]: Define energia
## - comp [nome] [valor]: Define competência
## - flag [nome] [valor]: Define flag
## - mission [id] start/complete: Controla missões
## - teleport [area]: Teletransporta para área
## - npc [id] [relationship]: Define relacionamento com NPC
## - skip_tutorial: Pula o tutorial
## - clear: Limpa o console

# Node references
@onready var panel: PanelContainer = $Panel
@onready var output: RichTextLabel = $Panel/VBox/Output
@onready var input: LineEdit = $Panel/VBox/Input

# State
var is_open := false
var command_history: Array[String] = []
var history_index := 0

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	panel.visible = false
	input.text_submitted.connect(_on_input_submitted)

	# Only enable in debug builds
	if not OS.is_debug_build():
		queue_free()
		return

	print("[DebugConsole] Ready (F12 to toggle)")


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			toggle()
			get_viewport().set_input_as_handled()
		elif is_open:
			if event.keycode == KEY_UP:
				_navigate_history(-1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_DOWN:
				_navigate_history(1)
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_ESCAPE:
				close()
				get_viewport().set_input_as_handled()


# ===========================================
# Console Control
# ===========================================

func toggle() -> void:
	if is_open:
		close()
	else:
		open()


func open() -> void:
	is_open = true
	panel.visible = true
	input.grab_focus()
	_log("[color=cyan]Debug Console - Digite 'help' para comandos[/color]")


func close() -> void:
	is_open = false
	panel.visible = false


func _log(text: String) -> void:
	output.append_text(text + "\n")


func _log_error(text: String) -> void:
	output.append_text("[color=red]Erro: " + text + "[/color]\n")


func _log_success(text: String) -> void:
	output.append_text("[color=green]" + text + "[/color]\n")


# ===========================================
# Input Handling
# ===========================================

func _on_input_submitted(text: String) -> void:
	if text.strip_edges() == "":
		return

	# Add to history
	command_history.append(text)
	history_index = command_history.size()

	# Log command
	_log("[color=yellow]> " + text + "[/color]")

	# Parse and execute
	_execute_command(text)

	# Clear input
	input.clear()


func _navigate_history(direction: int) -> void:
	if command_history.is_empty():
		return

	history_index = clamp(history_index + direction, 0, command_history.size() - 1)
	input.text = command_history[history_index]
	input.caret_column = input.text.length()


# ===========================================
# Command Execution
# ===========================================

func _execute_command(text: String) -> void:
	var parts := text.strip_edges().split(" ", false)
	if parts.is_empty():
		return

	var cmd := parts[0].to_lower()
	var args := parts.slice(1)

	match cmd:
		"help":
			_cmd_help()
		"clear":
			output.clear()
		"energy":
			_cmd_energy(args)
		"comp", "competency":
			_cmd_competency(args)
		"flag":
			_cmd_flag(args)
		"mission":
			_cmd_mission(args)
		"teleport", "tp":
			_cmd_teleport(args)
		"npc":
			_cmd_npc(args)
		"skip_tutorial":
			_cmd_skip_tutorial()
		"info":
			_cmd_info()
		"save":
			_cmd_save()
		"load":
			_cmd_load(args)
		"reload":
			_cmd_reload()
		_:
			_log_error("Comando desconhecido: " + cmd)


func _cmd_help() -> void:
	_log("""[color=white]Comandos disponíveis:[/color]
  help            - Mostra esta ajuda
  clear           - Limpa o console
  info            - Mostra estado do jogo
  energy [valor]  - Define energia (0-100)
  comp [nome] [valor] - Define competência
  flag [nome] [valor] - Define flag do mundo
  mission [id] [start|complete] - Controla missões
  teleport [area] - Teletransporta para área
  npc [id] [relationship] - Define relacionamento
  skip_tutorial   - Pula o tutorial
  save            - Salva o jogo
  load [slot]     - Carrega jogo do slot
  reload          - Recarrega cena atual""")


func _cmd_energy(args: Array) -> void:
	if args.is_empty():
		_log("Energia atual: %d/%d" % [GameManager.energy, GameManager.MAX_ENERGY])
		return

	var value := int(args[0])
	GameManager.energy = clamp(value, 0, GameManager.MAX_ENERGY)
	_log_success("Energia definida para: %d" % GameManager.energy)


func _cmd_competency(args: Array) -> void:
	if args.size() < 2:
		_log("Competências atuais:")
		for key in GameManager.competencies:
			_log("  %s: %d" % [key, GameManager.competencies[key]])
		return

	var name := args[0]
	var value := int(args[1])
	GameManager.competencies[name] = clamp(value, 0, 100)
	_log_success("Competência '%s' definida para: %d" % [name, value])


func _cmd_flag(args: Array) -> void:
	if args.size() < 2:
		_log("Flags do mundo:")
		for key in GameManager.world_flags:
			_log("  %s: %s" % [key, str(GameManager.world_flags[key])])
		return

	var name := args[0]
	var value_str := args[1].to_lower()
	var value: Variant

	if value_str == "true":
		value = true
	elif value_str == "false":
		value = false
	else:
		value = value_str

	GameManager.set_flag(name, value)
	_log_success("Flag '%s' definida para: %s" % [name, str(value)])


func _cmd_mission(args: Array) -> void:
	if args.is_empty():
		_log("Missões ativas:")
		for mission in MissionManager.get_active_missions():
			_log("  [%s] %s - %.0f%%" % [mission.id, mission.title, mission.get_progress() * 100])
		return

	if args.size() < 2:
		_log_error("Uso: mission [id] [start|complete]")
		return

	var mission_id := args[0]
	var action := args[1].to_lower()

	match action:
		"start":
			if MissionManager.start_mission(mission_id):
				_log_success("Missão iniciada: " + mission_id)
			else:
				_log_error("Não foi possível iniciar missão: " + mission_id)
		"complete":
			if MissionManager.force_complete_mission(mission_id):
				_log_success("Missão completada: " + mission_id)
			else:
				_log_error("Não foi possível completar missão: " + mission_id)
		_:
			_log_error("Ação inválida. Use 'start' ou 'complete'")


func _cmd_teleport(args: Array) -> void:
	if args.is_empty():
		_log("Áreas disponíveis: praca_central, escola, oficina, biblioteca")
		return

	var area := args[0]
	GameManager.current_area = area
	SceneManager.change_area(area)
	_log_success("Teletransportado para: " + area)


func _cmd_npc(args: Array) -> void:
	if args.size() < 2:
		_log("Uso: npc [id] [relationship_value]")
		return

	var npc_id := args[0]
	var value := int(args[1])

	if DialogueManager.npc_memory:
		DialogueManager.npc_memory.set_relationship(npc_id, value)
		_log_success("Relacionamento com '%s' definido para: %d" % [npc_id, value])
	else:
		_log_error("NPC memory não disponível")


func _cmd_skip_tutorial() -> void:
	TutorialManager.skip_tutorial()
	_log_success("Tutorial pulado")


func _cmd_info() -> void:
	_log("[color=white]Estado do Jogo:[/color]")
	_log("  Jogador: %s" % GameManager.player_name)
	_log("  Região: %s" % GameManager.current_region)
	_log("  Área: %s" % GameManager.current_area)
	_log("  Energia: %d/%d" % [GameManager.energy, GameManager.MAX_ENERGY])
	_log("  Estado: %s" % GameManager.GameState.keys()[GameManager.current_state])
	_log("  Missões ativas: %d" % MissionManager.get_active_missions().size())
	_log("  Tutorial: %s" % ("ativo" if TutorialManager.is_tutorial_active else "completo/inativo"))


func _cmd_save() -> void:
	if SaveManager.save_game():
		_log_success("Jogo salvo no slot %d" % SaveManager.current_slot)
	else:
		_log_error("Falha ao salvar o jogo")


func _cmd_load(args: Array) -> void:
	var slot := 1
	if not args.is_empty():
		slot = int(args[0])

	if SaveManager.load_game(slot):
		_log_success("Jogo carregado do slot %d" % slot)
	else:
		_log_error("Falha ao carregar o jogo do slot %d" % slot)


func _cmd_reload() -> void:
	SceneManager.reload_current_scene()
	_log_success("Cena recarregada")
