extends Node
## DialogueManager - Gerenciador central de diálogos
##
## Responsável por:
## - Carregar e parsear arquivos de diálogo
## - Controlar fluxo de diálogos
## - Emitir sinais para UI

# Signals
signal dialogue_started(dialogue_id: String, npc_name: String)
signal dialogue_ended(dialogue_id: String)
signal line_started(line: DialogueLine)
signal line_ended()
signal choices_presented(choices: Array[DialogueChoice])
signal choice_made(choice: DialogueChoice)
signal variable_changed(var_name: String, value: Variant)

# Types
class DialogueLine:
	var id: String = ""
	var speaker: String = ""
	var text: String = ""
	var portrait: String = ""
	var emotion: String = "neutral"
	var next: String = ""  # Next line ID or empty for end
	var choices: Array[DialogueChoice] = []
	var conditions: Array[DialogueCondition] = []
	var effects: Array[DialogueEffect] = []

class DialogueChoice:
	var id: String = ""
	var text: String = ""
	var next: String = ""  # Next line ID after choice
	var conditions: Array[DialogueCondition] = []
	var effects: Array[DialogueEffect] = []
	var competency_effects: Dictionary = {}  # {competency: delta}

class DialogueCondition:
	var type: String = ""  # "flag", "variable", "competency", "energy"
	var key: String = ""
	var operator: String = "=="  # ==, !=, >, <, >=, <=
	var value: Variant = null

class DialogueEffect:
	var type: String = ""  # "set_flag", "set_variable", "add_competency", "use_energy"
	var key: String = ""
	var value: Variant = null

# State
var current_dialogue_id: String = ""
var current_line_id: String = ""
var current_dialogue_data: Dictionary = {}
var current_npc_id: String = ""
var is_dialogue_active: bool = false
var dialogue_variables: Dictionary = {}

# Loaded dialogues cache
var dialogue_cache: Dictionary = {}

# NPC Memory reference (loaded on ready)
var npc_memory: NPCMemory = null

# Paths
const DIALOGUES_PATH := "res://data/dialogues/"

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	# Create NPCMemory instance
	npc_memory = NPCMemory.new()
	npc_memory.name = "NPCMemory"
	add_child(npc_memory)

	print("[DialogueManager] Initialized")


# ===========================================
# Dialogue Loading
# ===========================================

func load_dialogue(dialogue_id: String) -> bool:
	if dialogue_cache.has(dialogue_id):
		current_dialogue_data = dialogue_cache[dialogue_id]
		return true

	var file_path := DIALOGUES_PATH + dialogue_id + ".json"

	if not FileAccess.file_exists(file_path):
		push_error("[DialogueManager] Dialogue file not found: %s" % file_path)
		return false

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("[DialogueManager] Failed to open dialogue file: %s" % file_path)
		return false

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_text)

	if error != OK:
		push_error("[DialogueManager] Failed to parse dialogue JSON: %s" % json.get_error_message())
		return false

	current_dialogue_data = json.data
	dialogue_cache[dialogue_id] = current_dialogue_data

	print("[DialogueManager] Loaded dialogue: %s" % dialogue_id)
	return true


func reload_dialogue(dialogue_id: String) -> bool:
	dialogue_cache.erase(dialogue_id)
	return load_dialogue(dialogue_id)


# ===========================================
# Dialogue Flow
# ===========================================

func start_dialogue(dialogue_id: String, start_line: String = "") -> bool:
	if is_dialogue_active:
		push_warning("[DialogueManager] Dialogue already active")
		return false

	if not load_dialogue(dialogue_id):
		return false

	current_dialogue_id = dialogue_id
	current_npc_id = current_dialogue_data.get("npc_id", "")
	is_dialogue_active = true

	# Get start line
	if start_line == "":
		start_line = current_dialogue_data.get("start", "start")

	# Set game state
	GameManager.set_state(GameManager.GameState.DIALOGUE)

	# Record interaction with NPC
	if current_npc_id != "" and npc_memory:
		npc_memory.record_interaction(current_npc_id, dialogue_id)

	var npc_name: String = current_dialogue_data.get("npc_name", "???")
	dialogue_started.emit(dialogue_id, npc_name)

	print("[DialogueManager] Started dialogue: %s" % dialogue_id)

	# Show first line
	_show_line(start_line)

	return true


func advance_dialogue() -> void:
	if not is_dialogue_active:
		return

	var line_data := _get_line_data(current_line_id)
	if line_data.is_empty():
		end_dialogue()
		return

	# If line has choices, wait for choice selection
	var choices: Array = line_data.get("choices", [])
	if choices.size() > 0:
		return  # Wait for choice

	# Get next line
	var next_line: String = line_data.get("next", "")

	if next_line == "" or next_line == "end":
		end_dialogue()
	else:
		_show_line(next_line)


func select_choice(choice_index: int) -> void:
	if not is_dialogue_active:
		return

	var line_data := _get_line_data(current_line_id)
	var choices: Array = line_data.get("choices", [])

	if choice_index < 0 or choice_index >= choices.size():
		push_error("[DialogueManager] Invalid choice index: %d" % choice_index)
		return

	var choice_data: Dictionary = choices[choice_index]
	var choice := _parse_choice(choice_data)

	# Apply effects
	_apply_effects(choice.effects)

	# Apply competency effects
	for competency in choice.competency_effects:
		var delta: int = choice.competency_effects[competency]
		GameManager.add_competency(competency, delta)

	# Record choice in NPC memory and add relationship points
	if current_npc_id != "" and npc_memory:
		npc_memory.record_choice(current_npc_id, choice.id)
		# Add relationship points based on choice (default: 2 per interaction)
		var relationship_delta: int = choice_data.get("relationship_points", 2)
		npc_memory.add_relationship_points(current_npc_id, relationship_delta)

	# Log the choice
	_log_choice(choice)

	choice_made.emit(choice)

	# Move to next line
	var next_line: String = choice.next
	if next_line == "" or next_line == "end":
		end_dialogue()
	else:
		_show_line(next_line)


func end_dialogue() -> void:
	if not is_dialogue_active:
		return

	print("[DialogueManager] Ended dialogue: %s" % current_dialogue_id)

	line_ended.emit()
	dialogue_ended.emit(current_dialogue_id)

	is_dialogue_active = false
	current_dialogue_id = ""
	current_line_id = ""
	current_npc_id = ""
	current_dialogue_data = {}

	# Restore game state
	GameManager.set_state(GameManager.GameState.PLAYING)


# ===========================================
# Line Processing
# ===========================================

func _show_line(line_id: String) -> void:
	current_line_id = line_id
	var line_data := _get_line_data(line_id)

	if line_data.is_empty():
		push_error("[DialogueManager] Line not found: %s" % line_id)
		end_dialogue()
		return

	var line := _parse_line(line_data)

	# Check conditions
	if not _check_conditions(line.conditions):
		# Skip to next line
		var next_line: String = line_data.get("next", "")
		if next_line == "" or next_line == "end":
			end_dialogue()
		else:
			_show_line(next_line)
		return

	# Apply effects
	_apply_effects(line.effects)

	# Process text variables
	line.text = _process_variables(line.text)

	line_started.emit(line)

	# If line has choices, present them
	if line.choices.size() > 0:
		var valid_choices: Array[DialogueChoice] = []
		for choice in line.choices:
			if _check_conditions(choice.conditions):
				valid_choices.append(choice)

		if valid_choices.size() > 0:
			choices_presented.emit(valid_choices)


func _get_line_data(line_id: String) -> Dictionary:
	var lines: Dictionary = current_dialogue_data.get("lines", {})
	return lines.get(line_id, {})


func _parse_line(data: Dictionary) -> DialogueLine:
	var line := DialogueLine.new()
	line.id = data.get("id", "")
	line.speaker = data.get("speaker", current_dialogue_data.get("npc_name", "???"))
	line.text = data.get("text", "")
	line.portrait = data.get("portrait", current_dialogue_data.get("portrait", ""))
	line.emotion = data.get("emotion", "neutral")
	line.next = data.get("next", "")

	# Parse conditions
	for cond_data in data.get("conditions", []):
		line.conditions.append(_parse_condition(cond_data))

	# Parse effects
	for effect_data in data.get("effects", []):
		line.effects.append(_parse_effect(effect_data))

	# Parse choices
	for choice_data in data.get("choices", []):
		line.choices.append(_parse_choice(choice_data))

	return line


func _parse_choice(data: Dictionary) -> DialogueChoice:
	var choice := DialogueChoice.new()
	choice.id = data.get("id", "")
	choice.text = data.get("text", "")
	choice.next = data.get("next", "")
	choice.competency_effects = data.get("competency_effects", {})

	for cond_data in data.get("conditions", []):
		choice.conditions.append(_parse_condition(cond_data))

	for effect_data in data.get("effects", []):
		choice.effects.append(_parse_effect(effect_data))

	return choice


func _parse_condition(data: Dictionary) -> DialogueCondition:
	var cond := DialogueCondition.new()
	cond.type = data.get("type", "flag")
	cond.key = data.get("key", "")
	cond.operator = data.get("operator", "==")
	cond.value = data.get("value", true)
	return cond


func _parse_effect(data: Dictionary) -> DialogueEffect:
	var effect := DialogueEffect.new()
	effect.type = data.get("type", "set_flag")
	effect.key = data.get("key", "")
	effect.value = data.get("value", true)
	return effect


# ===========================================
# Conditions & Effects
# ===========================================

func _check_conditions(conditions: Array[DialogueCondition]) -> bool:
	for cond in conditions:
		if not _evaluate_condition(cond):
			return false
	return true


func _evaluate_condition(cond: DialogueCondition) -> bool:
	var actual_value: Variant

	match cond.type:
		"flag":
			actual_value = GameManager.get_flag(cond.key)
		"variable":
			actual_value = dialogue_variables.get(cond.key, null)
		"competency":
			actual_value = GameManager.get_competency_level(cond.key)
		"energy":
			actual_value = GameManager.energy
		"relationship":
			# Check relationship level with current NPC
			if npc_memory and current_npc_id != "":
				actual_value = npc_memory.get_relationship_points(current_npc_id)
			else:
				actual_value = 0
		"times_talked":
			# Check how many times player talked to current NPC
			if npc_memory and current_npc_id != "":
				actual_value = npc_memory.get_npc_data(current_npc_id).times_talked
			else:
				actual_value = 0
		"has_met":
			# Check if player has met this NPC before
			if npc_memory:
				actual_value = npc_memory.has_met_npc(cond.key)
			else:
				actual_value = false
		"npc_flag":
			# Check NPC-specific flag (key format: "npc_id.flag_name" or just "flag_name" for current NPC)
			if npc_memory:
				var parts := cond.key.split(".")
				if parts.size() == 2:
					actual_value = npc_memory.get_npc_flag(parts[0], parts[1])
				elif current_npc_id != "":
					actual_value = npc_memory.get_npc_flag(current_npc_id, cond.key)
				else:
					actual_value = null
			else:
				actual_value = null
		"made_choice":
			# Check if player made a specific choice with current NPC
			if npc_memory and current_npc_id != "":
				actual_value = npc_memory.has_made_choice(current_npc_id, cond.key)
			else:
				actual_value = false
		_:
			return true

	return _compare_values(actual_value, cond.operator, cond.value)


func _compare_values(actual: Variant, op: String, expected: Variant) -> bool:
	match op:
		"==":
			return actual == expected
		"!=":
			return actual != expected
		">":
			return actual > expected
		"<":
			return actual < expected
		">=":
			return actual >= expected
		"<=":
			return actual <= expected
		_:
			return actual == expected


func _apply_effects(effects: Array[DialogueEffect]) -> void:
	for effect in effects:
		_apply_effect(effect)


func _apply_effect(effect: DialogueEffect) -> void:
	match effect.type:
		"set_flag":
			GameManager.set_flag(effect.key, effect.value)
		"set_variable":
			dialogue_variables[effect.key] = effect.value
			variable_changed.emit(effect.key, effect.value)
		"add_competency":
			GameManager.add_competency(effect.key, effect.value)
		"use_energy":
			GameManager.use_energy(effect.value)
		"add_relationship":
			# Add relationship points with current NPC
			if npc_memory and current_npc_id != "":
				npc_memory.add_relationship_points(current_npc_id, effect.value)
		"set_npc_flag":
			# Set NPC-specific flag (key format: "npc_id.flag_name" or just "flag_name" for current NPC)
			if npc_memory:
				var parts := effect.key.split(".")
				if parts.size() == 2:
					npc_memory.set_npc_flag(parts[0], parts[1], effect.value)
				elif current_npc_id != "":
					npc_memory.set_npc_flag(current_npc_id, effect.key, effect.value)


# ===========================================
# Variable Processing
# ===========================================

func _process_variables(text: String) -> String:
	# Replace {variable_name} with actual values
	var result := text

	# Player name
	result = result.replace("{player_name}", GameManager.player_name)

	# Energy
	result = result.replace("{energy}", str(GameManager.energy))

	# NPC relationship level name
	if npc_memory and current_npc_id != "":
		var npc_data := npc_memory.get_npc_data(current_npc_id)
		result = result.replace("{relationship_level}", npc_data.get_level_name())
		result = result.replace("{times_talked}", str(npc_data.times_talked))

	# Custom variables
	for var_name in dialogue_variables:
		result = result.replace("{%s}" % var_name, str(dialogue_variables[var_name]))

	# World flags
	var regex := RegEx.new()
	regex.compile("\\{flag:(\\w+)\\}")
	for match_result in regex.search_all(result):
		var flag_name := match_result.get_string(1)
		var flag_value := GameManager.get_flag(flag_name)
		result = result.replace(match_result.get_string(), str(flag_value))

	return result


# ===========================================
# Choice Logging
# ===========================================

func _log_choice(choice: DialogueChoice) -> void:
	var log_data := {
		"dialogue_id": current_dialogue_id,
		"line_id": current_line_id,
		"choice_id": choice.id,
		"choice_text": choice.text,
		"competency_effects": choice.competency_effects,
		"timestamp": Time.get_unix_time_from_system()
	}

	# Send to backend
	APIClient.record_choice(log_data)

	print("[DialogueManager] Choice logged: %s" % choice.text)


# ===========================================
# Utilities
# ===========================================

func set_variable(var_name: String, value: Variant) -> void:
	dialogue_variables[var_name] = value
	variable_changed.emit(var_name, value)


func get_variable(var_name: String, default: Variant = null) -> Variant:
	return dialogue_variables.get(var_name, default)


func clear_variables() -> void:
	dialogue_variables.clear()


# ===========================================
# NPC Memory Access
# ===========================================

func get_npc_memory() -> NPCMemory:
	return npc_memory


func has_met_npc(npc_id: String) -> bool:
	if npc_memory:
		return npc_memory.has_met_npc(npc_id)
	return false


func get_relationship_with(npc_id: String) -> int:
	if npc_memory:
		return npc_memory.get_relationship_points(npc_id)
	return 0


func get_relationship_level_with(npc_id: String) -> int:
	if npc_memory:
		return npc_memory.get_relationship_level(npc_id)
	return NPCMemory.RelationshipLevel.STRANGER


# ===========================================
# Persistence
# ===========================================

func save_npc_memory() -> Dictionary:
	if npc_memory:
		return npc_memory.save_to_dict()
	return {}


func load_npc_memory(data: Dictionary) -> void:
	if npc_memory:
		npc_memory.load_from_dict(data)
