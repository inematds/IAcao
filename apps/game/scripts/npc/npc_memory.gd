extends Node
class_name NPCMemory
## NPCMemory - Sistema de memória e relacionamento com NPCs
##
## Responsável por:
## - Rastrear relações do jogador com cada NPC
## - Lembrar interações anteriores
## - Personalizar diálogos baseado no histórico

# Relationship levels
enum RelationshipLevel {
	STRANGER,      # 0-19: Nunca falou ou pouca interação
	ACQUAINTANCE,  # 20-39: Conhecidos
	FRIEND,        # 40-59: Amigos
	CLOSE_FRIEND,  # 60-79: Amigos próximos
	BEST_FRIEND    # 80-100: Melhores amigos
}

# NPC Data structure
class NPCData:
	var npc_id: String = ""
	var times_talked: int = 0
	var relationship_points: int = 0
	var last_interaction_time: int = 0
	var first_met_time: int = 0
	var dialogue_history: Array[String] = []  # IDs dos diálogos vistos
	var choices_made: Dictionary = {}  # choice_id -> timestamp
	var flags: Dictionary = {}  # Custom NPC-specific flags

	func get_relationship_level() -> int:
		if relationship_points >= 80:
			return RelationshipLevel.BEST_FRIEND
		elif relationship_points >= 60:
			return RelationshipLevel.CLOSE_FRIEND
		elif relationship_points >= 40:
			return RelationshipLevel.FRIEND
		elif relationship_points >= 20:
			return RelationshipLevel.ACQUAINTANCE
		else:
			return RelationshipLevel.STRANGER

	func get_level_name() -> String:
		match get_relationship_level():
			RelationshipLevel.BEST_FRIEND:
				return "Melhor Amigo"
			RelationshipLevel.CLOSE_FRIEND:
				return "Amigo Próximo"
			RelationshipLevel.FRIEND:
				return "Amigo"
			RelationshipLevel.ACQUAINTANCE:
				return "Conhecido"
			_:
				return "Desconhecido"

	func to_dict() -> Dictionary:
		return {
			"npc_id": npc_id,
			"times_talked": times_talked,
			"relationship_points": relationship_points,
			"last_interaction_time": last_interaction_time,
			"first_met_time": first_met_time,
			"dialogue_history": dialogue_history,
			"choices_made": choices_made,
			"flags": flags
		}

	static func from_dict(data: Dictionary) -> NPCData:
		var npc_data := NPCData.new()
		npc_data.npc_id = data.get("npc_id", "")
		npc_data.times_talked = data.get("times_talked", 0)
		npc_data.relationship_points = data.get("relationship_points", 0)
		npc_data.last_interaction_time = data.get("last_interaction_time", 0)
		npc_data.first_met_time = data.get("first_met_time", 0)
		npc_data.dialogue_history = Array(data.get("dialogue_history", []), TYPE_STRING, "", null)
		npc_data.choices_made = data.get("choices_made", {})
		npc_data.flags = data.get("flags", {})
		return npc_data

# Singleton instance (set by GameManager or autoload)
static var instance: NPCMemory

# Storage
var npc_data: Dictionary = {}  # npc_id -> NPCData

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	instance = self
	print("[NPCMemory] Initialized")


# ===========================================
# Data Access
# ===========================================

func get_npc_data(npc_id: String) -> NPCData:
	if not npc_data.has(npc_id):
		var new_data := NPCData.new()
		new_data.npc_id = npc_id
		npc_data[npc_id] = new_data
	return npc_data[npc_id]


func has_met_npc(npc_id: String) -> bool:
	if not npc_data.has(npc_id):
		return false
	return npc_data[npc_id].times_talked > 0


func get_relationship_level(npc_id: String) -> int:
	return get_npc_data(npc_id).get_relationship_level()


func get_relationship_points(npc_id: String) -> int:
	return get_npc_data(npc_id).relationship_points


# ===========================================
# Interaction Tracking
# ===========================================

func record_interaction(npc_id: String, dialogue_id: String = "") -> void:
	var data := get_npc_data(npc_id)
	var now := int(Time.get_unix_time_from_system())

	data.times_talked += 1
	data.last_interaction_time = now

	if data.first_met_time == 0:
		data.first_met_time = now

	if dialogue_id != "" and dialogue_id not in data.dialogue_history:
		data.dialogue_history.append(dialogue_id)

	print("[NPCMemory] Recorded interaction with %s (total: %d)" % [npc_id, data.times_talked])


func record_choice(npc_id: String, choice_id: String) -> void:
	var data := get_npc_data(npc_id)
	data.choices_made[choice_id] = int(Time.get_unix_time_from_system())
	print("[NPCMemory] Recorded choice '%s' for NPC '%s'" % [choice_id, npc_id])


func has_seen_dialogue(npc_id: String, dialogue_id: String) -> bool:
	return dialogue_id in get_npc_data(npc_id).dialogue_history


func has_made_choice(npc_id: String, choice_id: String) -> bool:
	return choice_id in get_npc_data(npc_id).choices_made


# ===========================================
# Relationship Management
# ===========================================

func add_relationship_points(npc_id: String, points: int) -> void:
	var data := get_npc_data(npc_id)
	var old_level := data.get_relationship_level()

	data.relationship_points = clampi(data.relationship_points + points, 0, 100)

	var new_level := data.get_relationship_level()

	if new_level != old_level:
		print("[NPCMemory] Relationship with %s changed: %s -> %s" % [
			npc_id,
			RelationshipLevel.keys()[old_level],
			RelationshipLevel.keys()[new_level]
		])
		# Could emit signal here for UI notifications


func set_relationship_points(npc_id: String, points: int) -> void:
	get_npc_data(npc_id).relationship_points = clampi(points, 0, 100)


# ===========================================
# NPC Flags
# ===========================================

func set_npc_flag(npc_id: String, flag_name: String, value: Variant = true) -> void:
	get_npc_data(npc_id).flags[flag_name] = value


func get_npc_flag(npc_id: String, flag_name: String, default: Variant = null) -> Variant:
	return get_npc_data(npc_id).flags.get(flag_name, default)


func has_npc_flag(npc_id: String, flag_name: String) -> bool:
	var data := get_npc_data(npc_id)
	return data.flags.has(flag_name) and data.flags[flag_name]


# ===========================================
# Serialization
# ===========================================

func save_to_dict() -> Dictionary:
	var result := {}
	for npc_id in npc_data:
		result[npc_id] = npc_data[npc_id].to_dict()
	return result


func load_from_dict(data: Dictionary) -> void:
	npc_data.clear()
	for npc_id in data:
		npc_data[npc_id] = NPCData.from_dict(data[npc_id])
	print("[NPCMemory] Loaded data for %d NPCs" % npc_data.size())


func clear_all() -> void:
	npc_data.clear()


# ===========================================
# Utility
# ===========================================

func get_all_known_npcs() -> Array[String]:
	var result: Array[String] = []
	for npc_id in npc_data:
		if npc_data[npc_id].times_talked > 0:
			result.append(npc_id)
	return result


func get_friends() -> Array[String]:
	var result: Array[String] = []
	for npc_id in npc_data:
		var data: NPCData = npc_data[npc_id]
		if data.get_relationship_level() >= RelationshipLevel.FRIEND:
			result.append(npc_id)
	return result


func get_best_friends() -> Array[String]:
	var result: Array[String] = []
	for npc_id in npc_data:
		var data: NPCData = npc_data[npc_id]
		if data.get_relationship_level() == RelationshipLevel.BEST_FRIEND:
			result.append(npc_id)
	return result
