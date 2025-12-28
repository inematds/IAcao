extends Node
class_name ARIAManager
## ARIAManager - Gerenciador do sistema de IA mentora ARIA
##
## Responsável por:
## - Interface com o jogador para interações de IA
## - Gerenciamento de ações (Analisar, Sugerir, Simular, Melhorar)
## - Custo e consumo de energia
## - Construção de contexto para a IA

# Signals
signal aria_opened()
signal aria_closed()
signal action_started(action: ARIAAction)
signal action_completed(action: ARIAAction, response: String)
signal action_failed(action: ARIAAction, error: String)
signal energy_insufficient(required: int, available: int)

# Action types
enum ActionType {
	ANALYZE,    # Examinar situação e entender aspectos
	SUGGEST,    # Dar ideias e possibilidades
	SIMULATE,   # Mostrar possíveis consequências
	IMPROVE     # Analisar e sugerir melhorias
}

# Action data structure
class ARIAAction:
	var type: ActionType
	var name: String
	var description: String
	var energy_cost: int
	var icon: String
	var context: String = ""
	var response: String = ""
	var timestamp: int = 0

	func _init(t: ActionType, n: String, d: String, cost: int, i: String) -> void:
		type = t
		name = n
		description = d
		energy_cost = cost
		icon = i

# Action definitions
var actions: Array[ARIAAction] = []

# State
var is_open := false
var is_processing := false
var current_action: ARIAAction = null
var session_context: Dictionary = {}  # Current game context

# History
var action_history: Array[Dictionary] = []

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_setup_actions()
	print("[ARIAManager] Initialized with %d actions" % actions.size())


func _setup_actions() -> void:
	actions = [
		ARIAAction.new(
			ActionType.ANALYZE,
			"Analisar",
			"Examina a situação atual e ajuda a entender diferentes aspectos",
			10,
			"🔍"
		),
		ARIAAction.new(
			ActionType.SUGGEST,
			"Sugerir",
			"Oferece ideias e possibilidades para você considerar",
			15,
			"💡"
		),
		ARIAAction.new(
			ActionType.SIMULATE,
			"Simular",
			"Mostra possíveis consequências de uma escolha",
			15,
			"🔮"
		),
		ARIAAction.new(
			ActionType.IMPROVE,
			"Melhorar",
			"Analisa algo que você criou e sugere melhorias",
			20,
			"✨"
		)
	]


func _input(event: InputEvent) -> void:
	# Open ARIA with 'A' key (when not in dialogue)
	if event.is_action_pressed("aria"):
		if GameManager.current_state == GameManager.GameState.PLAYING:
			if not is_open:
				open_aria()
		elif is_open and not is_processing:
			close_aria()


# ===========================================
# ARIA Interface
# ===========================================

func open_aria() -> void:
	if is_open:
		return

	is_open = true
	_build_session_context()

	GameManager.set_state(GameManager.GameState.DIALOGUE)
	aria_opened.emit()

	print("[ARIA] Interface opened")


func close_aria() -> void:
	if not is_open or is_processing:
		return

	is_open = false
	current_action = null

	GameManager.set_state(GameManager.GameState.PLAYING)
	aria_closed.emit()

	print("[ARIA] Interface closed")


func get_actions() -> Array[ARIAAction]:
	return actions


func get_action_by_type(type: ActionType) -> ARIAAction:
	for action in actions:
		if action.type == type:
			return action
	return null


func can_perform_action(action: ARIAAction) -> bool:
	return GameManager.has_energy(action.energy_cost) and not is_processing


# ===========================================
# Action Execution
# ===========================================

func perform_action(action: ARIAAction, additional_context: String = "") -> void:
	if is_processing:
		push_warning("[ARIA] Action already in progress")
		return

	if not GameManager.has_energy(action.energy_cost):
		energy_insufficient.emit(action.energy_cost, GameManager.energy)
		print("[ARIA] Insufficient energy: need %d, have %d" % [action.energy_cost, GameManager.energy])
		return

	# Consume energy
	GameManager.use_energy(action.energy_cost)

	# Set processing state
	is_processing = true
	current_action = action
	current_action.context = additional_context
	current_action.timestamp = int(Time.get_unix_time_from_system())

	action_started.emit(action)

	print("[ARIA] Executing action: %s (cost: %d)" % [action.name, action.energy_cost])

	# Build full context
	var full_context := _build_action_context(action, additional_context)

	# Make API request
	var response := await APIClient.query_aria(_get_action_string(action.type), full_context)

	is_processing = false

	if response.get("success", false):
		var data: Dictionary = response.get("data", {})
		var aria_response: String = data.get("response", "Desculpe, não consegui processar sua pergunta.")

		current_action.response = aria_response

		# Log to history
		_log_action(action, aria_response)

		action_completed.emit(action, aria_response)
		print("[ARIA] Action completed successfully")
	else:
		var error_msg: String = response.get("error", {}).get("message", "Erro desconhecido")
		action_failed.emit(action, error_msg)
		print("[ARIA] Action failed: %s" % error_msg)


func _get_action_string(type: ActionType) -> String:
	match type:
		ActionType.ANALYZE:
			return "analyze"
		ActionType.SUGGEST:
			return "suggest"
		ActionType.SIMULATE:
			return "simulate"
		ActionType.IMPROVE:
			return "improve"
		_:
			return "analyze"


# ===========================================
# Context Building
# ===========================================

func _build_session_context() -> void:
	session_context = {
		"player_name": GameManager.player_name,
		"current_region": GameManager.current_region,
		"current_area": GameManager.current_area,
		"energy": GameManager.energy,
		"competencies": GameManager.competencies.duplicate(),
		"world_flags": _get_relevant_flags(),
		"recent_dialogues": _get_recent_dialogues(),
		"nearby_npcs": _get_nearby_npcs()
	}


func _build_action_context(action: ARIAAction, additional: String) -> String:
	var context_parts: Array[String] = []

	# Player context
	context_parts.append("Jogador: %s" % session_context.get("player_name", "Jogador"))
	context_parts.append("Local: %s - %s" % [
		session_context.get("current_region", "Vila"),
		session_context.get("current_area", "Centro")
	])

	# Competencies summary
	var comps: Dictionary = session_context.get("competencies", {})
	if not comps.is_empty():
		var comp_str := "Competências: "
		var comp_list: Array[String] = []
		for key in comps:
			comp_list.append("%s: %d" % [key, comps[key]])
		comp_str += ", ".join(comp_list)
		context_parts.append(comp_str)

	# Recent interactions
	var recent := session_context.get("recent_dialogues", []) as Array
	if not recent.is_empty():
		context_parts.append("Interações recentes: " + ", ".join(recent))

	# Nearby NPCs
	var npcs := session_context.get("nearby_npcs", []) as Array
	if not npcs.is_empty():
		context_parts.append("NPCs próximos: " + ", ".join(npcs))

	# Additional context from user
	if additional != "":
		context_parts.append("Contexto adicional: " + additional)

	return "\n".join(context_parts)


func _get_relevant_flags() -> Array[String]:
	var flags: Array[String] = []
	var all_flags := GameManager.world_flags

	# Filter for relevant flags (not internal ones)
	for flag_name in all_flags:
		if all_flags[flag_name] and not flag_name.begins_with("_"):
			flags.append(flag_name)

	return flags


func _get_recent_dialogues() -> Array[String]:
	var recent: Array[String] = []

	# Get from DialogueManager's NPC memory
	if DialogueManager.npc_memory:
		var known := DialogueManager.npc_memory.get_all_known_npcs()
		for npc_id in known.slice(0, 5):  # Last 5 NPCs
			recent.append(npc_id)

	return recent


func _get_nearby_npcs() -> Array[String]:
	var npcs: Array[String] = []

	# Find NPCs in the scene
	var npc_nodes := get_tree().get_nodes_in_group("npcs")
	for npc in npc_nodes:
		if npc.has_method("get") and npc.get("npc_name"):
			npcs.append(npc.npc_name)

	return npcs


# ===========================================
# History & Logging
# ===========================================

func _log_action(action: ARIAAction, response: String) -> void:
	var log_entry := {
		"action_type": ActionType.keys()[action.type],
		"action_name": action.name,
		"energy_cost": action.energy_cost,
		"context": action.context,
		"response_preview": response.substr(0, 100),  # First 100 chars
		"timestamp": action.timestamp,
		"region": GameManager.current_region,
		"area": GameManager.current_area
	}

	action_history.append(log_entry)

	# Keep only last 50 entries
	if action_history.size() > 50:
		action_history = action_history.slice(-50)


func get_action_history() -> Array[Dictionary]:
	return action_history


func get_last_response() -> String:
	if current_action:
		return current_action.response
	return ""


# ===========================================
# Competency Tracking
# ===========================================

func record_aria_usage(action_type: ActionType) -> void:
	# Track ARIA usage for analytics and competency development
	match action_type:
		ActionType.ANALYZE:
			GameManager.add_competency("critical_thinking", 1)
		ActionType.SUGGEST:
			GameManager.add_competency("creativity", 1)
		ActionType.SIMULATE:
			GameManager.add_competency("critical_thinking", 1)
		ActionType.IMPROVE:
			GameManager.add_competency("communication", 1)


# ===========================================
# Serialization
# ===========================================

func save_data() -> Dictionary:
	return {
		"action_history": action_history
	}


func load_data(data: Dictionary) -> void:
	action_history = data.get("action_history", [])
