extends Node
class_name MissionManager
## MissionManager - Sistema de missões e quests
##
## Responsável por:
## - Gerenciar missões ativas e completadas
## - Rastrear objetivos
## - Aplicar recompensas
## - Integrar com sistema de competências

# Signals
signal mission_started(mission: Mission)
signal mission_updated(mission: Mission, objective_id: String)
signal mission_completed(mission: Mission)
signal mission_failed(mission: Mission)
signal objective_completed(mission: Mission, objective: MissionObjective)
signal reward_received(reward: MissionReward)

# Mission status
enum MissionStatus {
	AVAILABLE,
	ACTIVE,
	COMPLETED,
	FAILED,
	LOCKED
}

# Objective types
enum ObjectiveType {
	TALK_TO_NPC,       # Falar com NPC específico
	COLLECT_ITEM,      # Coletar itens
	REACH_LOCATION,    # Chegar em um local
	MAKE_CHOICE,       # Fazer uma escolha específica
	USE_ARIA,          # Usar ARIA X vezes
	REACH_COMPETENCY,  # Atingir nível de competência
	COMPLETE_DIALOGUE, # Completar diálogo
	CUSTOM             # Objetivo customizado
}

# Data structures
class Mission:
	var id: String = ""
	var title: String = ""
	var description: String = ""
	var giver_npc: String = ""  # NPC que dá a missão
	var region: String = ""
	var status: MissionStatus = MissionStatus.AVAILABLE
	var objectives: Array[MissionObjective] = []
	var rewards: Array[MissionReward] = []
	var requirements: Dictionary = {}  # Pré-requisitos
	var time_limit: float = 0.0  # 0 = sem limite
	var is_main_quest: bool = false
	var order: int = 0  # Para ordenação
	var started_at: int = 0
	var completed_at: int = 0

	func is_complete() -> bool:
		for obj in objectives:
			if not obj.is_complete:
				return false
		return true

	func get_progress() -> float:
		if objectives.is_empty():
			return 0.0
		var completed := 0
		for obj in objectives:
			if obj.is_complete:
				completed += 1
		return float(completed) / float(objectives.size())

	func to_dict() -> Dictionary:
		var obj_list := []
		for obj in objectives:
			obj_list.append(obj.to_dict())
		var rew_list := []
		for rew in rewards:
			rew_list.append(rew.to_dict())
		return {
			"id": id,
			"status": MissionStatus.keys()[status],
			"objectives": obj_list,
			"started_at": started_at,
			"completed_at": completed_at
		}

class MissionObjective:
	var id: String = ""
	var type: ObjectiveType = ObjectiveType.CUSTOM
	var description: String = ""
	var target: String = ""  # ID do alvo (NPC, item, local, etc)
	var target_count: int = 1
	var current_count: int = 0
	var is_complete: bool = false
	var is_optional: bool = false
	var hidden: bool = false  # Objetivo oculto até ser revelado

	func check_completion() -> bool:
		is_complete = current_count >= target_count
		return is_complete

	func to_dict() -> Dictionary:
		return {
			"id": id,
			"current_count": current_count,
			"is_complete": is_complete
		}

class MissionReward:
	var type: String = ""  # "energy", "competency", "item", "flag", "unlock"
	var key: String = ""
	var value: Variant = null
	var description: String = ""

	func to_dict() -> Dictionary:
		return {
			"type": type,
			"key": key,
			"value": value
		}

# Storage
var all_missions: Dictionary = {}  # id -> Mission
var active_missions: Array[String] = []
var completed_missions: Array[String] = []

# Mission data path
const MISSIONS_PATH := "res://data/missions/"

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_load_mission_definitions()
	_connect_game_events()
	print("[MissionManager] Initialized with %d missions" % all_missions.size())


func _load_mission_definitions() -> void:
	# Load built-in missions
	_define_tutorial_missions()
	_define_chapter1_missions()


func _connect_game_events() -> void:
	# Connect to dialogue events for objective tracking
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.choice_made.connect(_on_choice_made)

	# Connect to ARIA events
	ARIAManager.action_completed.connect(_on_aria_action_completed)


# ===========================================
# Mission Definitions
# ===========================================

func _define_tutorial_missions() -> void:
	# Tutorial: Meet ARIA
	var m1 := Mission.new()
	m1.id = "tutorial_aria"
	m1.title = "Conhecendo a ARIA"
	m1.description = "Descubra como usar sua assistente de IA para ajudar no aprendizado."
	m1.giver_npc = "aria"
	m1.is_main_quest = true
	m1.order = 1

	var obj1 := MissionObjective.new()
	obj1.id = "talk_aria"
	obj1.type = ObjectiveType.COMPLETE_DIALOGUE
	obj1.description = "Converse com a ARIA"
	obj1.target = "aria_intro"
	obj1.target_count = 1
	m1.objectives.append(obj1)

	var obj2 := MissionObjective.new()
	obj2.id = "use_aria"
	obj2.type = ObjectiveType.USE_ARIA
	obj2.description = "Use a ARIA para analisar algo"
	obj2.target = "analyze"
	obj2.target_count = 1
	m1.objectives.append(obj2)

	var rew1 := MissionReward.new()
	rew1.type = "competency"
	rew1.key = "digital_ethics"
	rew1.value = 5
	rew1.description = "+5 Ética Digital"
	m1.rewards.append(rew1)

	var rew2 := MissionReward.new()
	rew2.type = "energy"
	rew2.value = 20
	rew2.description = "+20 Energia"
	m1.rewards.append(rew2)

	all_missions[m1.id] = m1

	# Tutorial: Meet Dona Flora
	var m2 := Mission.new()
	m2.id = "tutorial_flora"
	m2.title = "A Guardiã das Histórias"
	m2.description = "Conheça Dona Flora e descubra as histórias de Vila Esperança."
	m2.giver_npc = "dona_flora"
	m2.is_main_quest = true
	m2.order = 2

	var obj_flora := MissionObjective.new()
	obj_flora.id = "meet_flora"
	obj_flora.type = ObjectiveType.COMPLETE_DIALOGUE
	obj_flora.description = "Converse com Dona Flora"
	obj_flora.target = "dona_flora"
	obj_flora.target_count = 1
	m2.objectives.append(obj_flora)

	var rew_flora := MissionReward.new()
	rew_flora.type = "competency"
	rew_flora.key = "communication"
	rew_flora.value = 3
	rew_flora.description = "+3 Comunicação"
	m2.rewards.append(rew_flora)

	all_missions[m2.id] = m2


func _define_chapter1_missions() -> void:
	# Chapter 1: Help Teco
	var m1 := Mission.new()
	m1.id = "ch1_help_teco"
	m1.title = "O Projeto do Teco"
	m1.description = "Ajude Teco com seu projeto de robótica usando suas habilidades."
	m1.giver_npc = "teco"
	m1.is_main_quest = true
	m1.order = 10
	m1.requirements = {"tutorial_aria": true}  # Requires completing ARIA tutorial

	var obj1 := MissionObjective.new()
	obj1.id = "talk_teco"
	obj1.type = ObjectiveType.COMPLETE_DIALOGUE
	obj1.description = "Fale com Teco na oficina"
	obj1.target = "teco_intro"
	obj1.target_count = 1
	m1.objectives.append(obj1)

	var obj2 := MissionObjective.new()
	obj2.id = "use_aria_suggest"
	obj2.type = ObjectiveType.USE_ARIA
	obj2.description = "Use ARIA para sugerir ideias"
	obj2.target = "suggest"
	obj2.target_count = 1
	m1.objectives.append(obj2)

	var obj3 := MissionObjective.new()
	obj3.id = "return_teco"
	obj3.type = ObjectiveType.TALK_TO_NPC
	obj3.description = "Volte para falar com Teco"
	obj3.target = "teco"
	obj3.target_count = 1
	m1.objectives.append(obj3)

	var rew1 := MissionReward.new()
	rew1.type = "competency"
	rew1.key = "creativity"
	rew1.value = 5
	rew1.description = "+5 Criatividade"
	m1.rewards.append(rew1)

	var rew2 := MissionReward.new()
	rew2.type = "competency"
	rew2.key = "collaboration"
	rew2.value = 3
	rew2.description = "+3 Colaboração"
	m1.rewards.append(rew2)

	all_missions[m1.id] = m1

	# Chapter 1: Community Problem (Main Quest 2)
	var m2 := Mission.new()
	m2.id = "ch1_community"
	m2.title = "O Problema da Comunidade"
	m2.description = "A praça central precisa de melhorias. Ajude a comunidade a encontrar uma solução."
	m2.giver_npc = "dona_flora"
	m2.is_main_quest = true
	m2.order = 20
	m2.requirements = {"ch1_help_teco": true}

	var obj_c1 := MissionObjective.new()
	obj_c1.id = "talk_flora_problem"
	obj_c1.type = ObjectiveType.COMPLETE_DIALOGUE
	obj_c1.description = "Fale com Dona Flora sobre o problema"
	obj_c1.target = "flora_problem"
	obj_c1.target_count = 1
	m2.objectives.append(obj_c1)

	var obj_c2 := MissionObjective.new()
	obj_c2.id = "gather_opinions"
	obj_c2.type = ObjectiveType.TALK_TO_NPC
	obj_c2.description = "Colete opiniões de 3 moradores"
	obj_c2.target = "any"
	obj_c2.target_count = 3
	m2.objectives.append(obj_c2)

	var obj_c3 := MissionObjective.new()
	obj_c3.id = "use_aria_analyze"
	obj_c3.type = ObjectiveType.USE_ARIA
	obj_c3.description = "Use ARIA para analisar as opiniões"
	obj_c3.target = "analyze"
	obj_c3.target_count = 1
	m2.objectives.append(obj_c3)

	var rew_c1 := MissionReward.new()
	rew_c1.type = "competency"
	rew_c1.key = "critical_thinking"
	rew_c1.value = 5
	rew_c1.description = "+5 Pensamento Crítico"
	m2.rewards.append(rew_c1)

	var rew_c2 := MissionReward.new()
	rew_c2.type = "competency"
	rew_c2.key = "collaboration"
	rew_c2.value = 5
	rew_c2.description = "+5 Colaboração"
	m2.rewards.append(rew_c2)

	all_missions[m2.id] = m2

	# Chapter 1: The Solution (Main Quest 3)
	var m3 := Mission.new()
	m3.id = "ch1_solution"
	m3.title = "A Solução Criativa"
	m3.description = "Com as informações coletadas, proponha uma solução para o problema da praça."
	m3.giver_npc = "dona_flora"
	m3.is_main_quest = true
	m3.order = 30
	m3.requirements = {"ch1_community": true}

	var obj_s1 := MissionObjective.new()
	obj_s1.id = "simulate_solution"
	obj_s1.type = ObjectiveType.USE_ARIA
	obj_s1.description = "Use ARIA para simular sua solução"
	obj_s1.target = "simulate"
	obj_s1.target_count = 1
	m3.objectives.append(obj_s1)

	var obj_s2 := MissionObjective.new()
	obj_s2.id = "present_to_flora"
	obj_s2.type = ObjectiveType.COMPLETE_DIALOGUE
	obj_s2.description = "Apresente sua ideia para Dona Flora"
	obj_s2.target = "flora_present"
	obj_s2.target_count = 1
	m3.objectives.append(obj_s2)

	var obj_s3 := MissionObjective.new()
	obj_s3.id = "convince_skeptic"
	obj_s3.type = ObjectiveType.MAKE_CHOICE
	obj_s3.description = "Convença o morador cético"
	obj_s3.target = "choice_convince"
	obj_s3.target_count = 1
	m3.objectives.append(obj_s3)

	var rew_s1 := MissionReward.new()
	rew_s1.type = "competency"
	rew_s1.key = "creativity"
	rew_s1.value = 8
	rew_s1.description = "+8 Criatividade"
	m3.rewards.append(rew_s1)

	var rew_s2 := MissionReward.new()
	rew_s2.type = "competency"
	rew_s2.key = "communication"
	rew_s2.value = 5
	rew_s2.description = "+5 Comunicação"
	m3.rewards.append(rew_s2)

	all_missions[m3.id] = m3

	# Chapter 1: The Vote (Main Quest 4)
	var m4 := Mission.new()
	m4.id = "ch1_vote"
	m4.title = "A Decisão da Vila"
	m4.description = "A comunidade vai votar nas propostas. Prepare-se para defender sua ideia."
	m4.giver_npc = "dona_flora"
	m4.is_main_quest = true
	m4.order = 40
	m4.requirements = {"ch1_solution": true}

	var obj_v1 := MissionObjective.new()
	obj_v1.id = "improve_proposal"
	obj_v1.type = ObjectiveType.USE_ARIA
	obj_v1.description = "Use ARIA para melhorar sua proposta"
	obj_v1.target = "improve"
	obj_v1.target_count = 1
	m4.objectives.append(obj_v1)

	var obj_v2 := MissionObjective.new()
	obj_v2.id = "talk_supporters"
	obj_v2.type = ObjectiveType.TALK_TO_NPC
	obj_v2.description = "Converse com 2 apoiadores"
	obj_v2.target = "any"
	obj_v2.target_count = 2
	m4.objectives.append(obj_v2)

	var obj_v3 := MissionObjective.new()
	obj_v3.id = "final_presentation"
	obj_v3.type = ObjectiveType.COMPLETE_DIALOGUE
	obj_v3.description = "Faça a apresentação final"
	obj_v3.target = "final_pitch"
	obj_v3.target_count = 1
	m4.objectives.append(obj_v3)

	var rew_v1 := MissionReward.new()
	rew_v1.type = "competency"
	rew_v1.key = "civic_responsibility"
	rew_v1.value = 10
	rew_v1.description = "+10 Responsabilidade Cívica"
	m4.rewards.append(rew_v1)

	var rew_v2 := MissionReward.new()
	rew_v2.type = "flag"
	rew_v2.key = "chapter1_complete"
	rew_v2.value = true
	rew_v2.description = "Capítulo 1 Completo!"
	m4.rewards.append(rew_v2)

	all_missions[m4.id] = m4

	# Chapter 1: Epilogue (Main Quest 5)
	var m5 := Mission.new()
	m5.id = "ch1_epilogue"
	m5.title = "Um Novo Começo"
	m5.description = "A vila celebra a decisão tomada. Veja os resultados do seu trabalho."
	m5.giver_npc = "dona_flora"
	m5.is_main_quest = true
	m5.order = 50
	m5.requirements = {"ch1_vote": true}

	var obj_e1 := MissionObjective.new()
	obj_e1.id = "see_results"
	obj_e1.type = ObjectiveType.REACH_LOCATION
	obj_e1.description = "Vá até a praça ver os resultados"
	obj_e1.target = "praca_central"
	obj_e1.target_count = 1
	m5.objectives.append(obj_e1)

	var obj_e2 := MissionObjective.new()
	obj_e2.id = "talk_celebration"
	obj_e2.type = ObjectiveType.TALK_TO_NPC
	obj_e2.description = "Converse com os moradores na celebração"
	obj_e2.target = "any"
	obj_e2.target_count = 2
	m5.objectives.append(obj_e2)

	var obj_e3 := MissionObjective.new()
	obj_e3.id = "reflection"
	obj_e3.type = ObjectiveType.USE_ARIA
	obj_e3.description = "Reflita sobre a jornada com ARIA"
	obj_e3.target = "analyze"
	obj_e3.target_count = 1
	m5.objectives.append(obj_e3)

	var rew_e1 := MissionReward.new()
	rew_e1.type = "energy"
	rew_e1.value = 50
	rew_e1.description = "+50 Energia"
	m5.rewards.append(rew_e1)

	var rew_e2 := MissionReward.new()
	rew_e2.type = "unlock"
	rew_e2.key = "chapter2"
	rew_e2.value = true
	rew_e2.description = "Capítulo 2 Desbloqueado!"
	m5.rewards.append(rew_e2)

	all_missions[m5.id] = m5

	# Side quest: Explore the village
	var side1 := Mission.new()
	side1.id = "side_explore"
	side1.title = "Explorador da Vila"
	side1.description = "Explore Vila Esperança e conheça seus habitantes."
	side1.is_main_quest = false
	side1.order = 5

	var obj_explore1 := MissionObjective.new()
	obj_explore1.id = "visit_escola"
	obj_explore1.type = ObjectiveType.REACH_LOCATION
	obj_explore1.description = "Visite a Escola"
	obj_explore1.target = "escola"
	obj_explore1.target_count = 1
	side1.objectives.append(obj_explore1)

	var obj_explore2 := MissionObjective.new()
	obj_explore2.id = "talk_3_npcs"
	obj_explore2.type = ObjectiveType.TALK_TO_NPC
	obj_explore2.description = "Converse com 3 moradores"
	obj_explore2.target = "any"
	obj_explore2.target_count = 3
	side1.objectives.append(obj_explore2)

	var rew_explore := MissionReward.new()
	rew_explore.type = "competency"
	rew_explore.key = "communication"
	rew_explore.value = 5
	rew_explore.description = "+5 Comunicação"
	side1.rewards.append(rew_explore)

	all_missions[side1.id] = side1


# ===========================================
# Mission Management
# ===========================================

func get_mission(mission_id: String) -> Mission:
	return all_missions.get(mission_id, null)


func get_active_missions() -> Array[Mission]:
	var result: Array[Mission] = []
	for mid in active_missions:
		if all_missions.has(mid):
			result.append(all_missions[mid])
	return result


func get_available_missions() -> Array[Mission]:
	var result: Array[Mission] = []
	for mid in all_missions:
		var mission: Mission = all_missions[mid]
		if mission.status == MissionStatus.AVAILABLE and _check_requirements(mission):
			result.append(mission)
	return result


func get_completed_missions() -> Array[Mission]:
	var result: Array[Mission] = []
	for mid in completed_missions:
		if all_missions.has(mid):
			result.append(all_missions[mid])
	return result


func _check_requirements(mission: Mission) -> bool:
	for req_id in mission.requirements:
		if not completed_missions.has(req_id):
			return false
	return true


# ===========================================
# Mission Flow
# ===========================================

func start_mission(mission_id: String) -> bool:
	if not all_missions.has(mission_id):
		push_error("[MissionManager] Mission not found: %s" % mission_id)
		return false

	var mission: Mission = all_missions[mission_id]

	if mission.status != MissionStatus.AVAILABLE:
		push_warning("[MissionManager] Mission not available: %s" % mission_id)
		return false

	if not _check_requirements(mission):
		push_warning("[MissionManager] Requirements not met for: %s" % mission_id)
		return false

	mission.status = MissionStatus.ACTIVE
	mission.started_at = int(Time.get_unix_time_from_system())
	active_missions.append(mission_id)

	mission_started.emit(mission)
	print("[MissionManager] Started mission: %s" % mission.title)

	return true


func complete_mission(mission_id: String) -> void:
	if not all_missions.has(mission_id):
		return

	var mission: Mission = all_missions[mission_id]

	if mission.status != MissionStatus.ACTIVE:
		return

	if not mission.is_complete():
		push_warning("[MissionManager] Mission objectives not complete: %s" % mission_id)
		return

	_finalize_mission(mission)


func force_complete_mission(mission_id: String) -> bool:
	## Force complete a mission (for debug purposes)
	if not all_missions.has(mission_id):
		return false

	var mission: Mission = all_missions[mission_id]

	# Force complete all objectives
	for obj in mission.objectives:
		obj.current_count = obj.target_count
		obj.is_complete = true

	# Start if not active
	if mission.status == MissionStatus.AVAILABLE:
		mission.status = MissionStatus.ACTIVE
		mission.started_at = int(Time.get_unix_time_from_system())
		if not active_missions.has(mission_id):
			active_missions.append(mission_id)

	if mission.status == MissionStatus.ACTIVE:
		_finalize_mission(mission)
		return true

	return false


func _finalize_mission(mission: Mission) -> void:
	mission.status = MissionStatus.COMPLETED
	mission.completed_at = int(Time.get_unix_time_from_system())

	active_missions.erase(mission.id)
	if not completed_missions.has(mission.id):
		completed_missions.append(mission.id)

	# Apply rewards
	_apply_rewards(mission)

	# Set completion flag
	GameManager.set_flag("mission_complete_" + mission.id, true)

	mission_completed.emit(mission)
	print("[MissionManager] Completed mission: %s" % mission.title)

	# Send to backend
	APIClient.complete_mission(mission.id, mission.to_dict())


func fail_mission(mission_id: String) -> void:
	if not all_missions.has(mission_id):
		return

	var mission: Mission = all_missions[mission_id]
	mission.status = MissionStatus.FAILED
	active_missions.erase(mission_id)

	mission_failed.emit(mission)
	print("[MissionManager] Failed mission: %s" % mission.title)


func _apply_rewards(mission: Mission) -> void:
	for reward in mission.rewards:
		match reward.type:
			"energy":
				GameManager.add_energy(reward.value)
			"competency":
				GameManager.add_competency(reward.key, reward.value)
			"flag":
				GameManager.set_flag(reward.key, reward.value)
			"item":
				# TODO: Implement inventory system
				pass

		reward_received.emit(reward)
		print("[MissionManager] Reward: %s" % reward.description)


# ===========================================
# Objective Tracking
# ===========================================

func update_objective(mission_id: String, objective_id: String, amount: int = 1) -> void:
	if not all_missions.has(mission_id):
		return

	var mission: Mission = all_missions[mission_id]

	if mission.status != MissionStatus.ACTIVE:
		return

	for obj in mission.objectives:
		if obj.id == objective_id and not obj.is_complete:
			obj.current_count = min(obj.current_count + amount, obj.target_count)

			if obj.check_completion():
				objective_completed.emit(mission, obj)
				print("[MissionManager] Objective complete: %s" % obj.description)

			mission_updated.emit(mission, objective_id)

			# Check if mission is complete
			if mission.is_complete():
				complete_mission(mission_id)

			break


func _check_objectives_for_event(event_type: ObjectiveType, target: String) -> void:
	for mid in active_missions:
		var mission: Mission = all_missions[mid]
		for obj in mission.objectives:
			if obj.type == event_type and not obj.is_complete:
				if obj.target == target or obj.target == "any":
					update_objective(mid, obj.id, 1)


# ===========================================
# Event Handlers
# ===========================================

func _on_dialogue_ended(dialogue_id: String) -> void:
	_check_objectives_for_event(ObjectiveType.COMPLETE_DIALOGUE, dialogue_id)

	# Also check NPC talk objectives
	var npc_id := dialogue_id.split("_")[0] if "_" in dialogue_id else dialogue_id
	_check_objectives_for_event(ObjectiveType.TALK_TO_NPC, npc_id)


func _on_choice_made(choice: DialogueManager.DialogueChoice) -> void:
	_check_objectives_for_event(ObjectiveType.MAKE_CHOICE, choice.id)


func _on_aria_action_completed(action: ARIAManager.ARIAAction, response: String) -> void:
	var action_name := ARIAManager.ActionType.keys()[action.type].to_lower()
	_check_objectives_for_event(ObjectiveType.USE_ARIA, action_name)


func on_location_reached(location_id: String) -> void:
	_check_objectives_for_event(ObjectiveType.REACH_LOCATION, location_id)


# ===========================================
# Persistence
# ===========================================

func save_data() -> Dictionary:
	var missions_data := {}
	for mid in all_missions:
		var mission: Mission = all_missions[mid]
		if mission.status != MissionStatus.AVAILABLE:
			missions_data[mid] = mission.to_dict()

	return {
		"active_missions": active_missions,
		"completed_missions": completed_missions,
		"missions": missions_data
	}


func load_data(data: Dictionary) -> void:
	active_missions = Array(data.get("active_missions", []), TYPE_STRING, "", null)
	completed_missions = Array(data.get("completed_missions", []), TYPE_STRING, "", null)

	var missions_data: Dictionary = data.get("missions", {})
	for mid in missions_data:
		if all_missions.has(mid):
			var mission: Mission = all_missions[mid]
			var mdata: Dictionary = missions_data[mid]

			mission.status = MissionStatus[mdata.get("status", "AVAILABLE")]
			mission.started_at = mdata.get("started_at", 0)
			mission.completed_at = mdata.get("completed_at", 0)

			var obj_data: Array = mdata.get("objectives", [])
			for i in range(min(obj_data.size(), mission.objectives.size())):
				mission.objectives[i].current_count = obj_data[i].get("current_count", 0)
				mission.objectives[i].is_complete = obj_data[i].get("is_complete", false)

	print("[MissionManager] Loaded %d active, %d completed missions" % [active_missions.size(), completed_missions.size()])
