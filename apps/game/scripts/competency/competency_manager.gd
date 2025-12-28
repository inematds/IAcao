extends Node
class_name CompetencyManager
## CompetencyManager - Sistema de competências do jogador
##
## Responsável por:
## - Definir e gerenciar competências
## - Calcular níveis e progressão
## - Emitir eventos de progresso
## - Verificar requisitos de competência

# Signals
signal competency_updated(type: String, old_value: int, new_value: int)
signal competency_level_up(type: String, new_level: int)
signal achievement_unlocked(achievement_id: String)

# Competency definitions
enum CompetencyType {
	CRITICAL_THINKING,
	CREATIVITY,
	COMMUNICATION,
	COLLABORATION,
	DIGITAL_ETHICS,
	LOGIC,
	PROBLEM_SOLVING
}

# Competency data structure
class CompetencyDef:
	var id: String
	var name: String
	var name_pt: String
	var description: String
	var icon: String
	var color: Color
	var levels: Array[LevelDef] = []

	func _init(i: String, n: String, pt: String, desc: String, ic: String, c: Color) -> void:
		id = i
		name = n
		name_pt = pt
		description = desc
		icon = ic
		color = c

class LevelDef:
	var level: int
	var name: String
	var min_points: int
	var max_points: int

	func _init(l: int, n: String, min_p: int, max_p: int) -> void:
		level = l
		name = n
		min_points = min_p
		max_points = max_p

# Competency definitions
var competency_defs: Dictionary = {}

# Level thresholds (shared across all competencies)
var level_thresholds: Array[LevelDef] = []

# Achievement definitions
var achievements: Dictionary = {}

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_setup_competencies()
	_setup_levels()
	_setup_achievements()
	print("[CompetencyManager] Initialized with %d competencies" % competency_defs.size())


func _setup_competencies() -> void:
	competency_defs = {
		"critical_thinking": CompetencyDef.new(
			"critical_thinking",
			"Critical Thinking",
			"Pensamento Crítico",
			"Capacidade de analisar informações, avaliar argumentos e tomar decisões fundamentadas.",
			"🧠",
			Color(0.6, 0.4, 0.8)
		),
		"creativity": CompetencyDef.new(
			"creativity",
			"Creativity",
			"Criatividade",
			"Habilidade de gerar ideias originais e encontrar soluções inovadoras para problemas.",
			"🎨",
			Color(1.0, 0.6, 0.2)
		),
		"communication": CompetencyDef.new(
			"communication",
			"Communication",
			"Comunicação",
			"Capacidade de expressar ideias claramente e compreender diferentes perspectivas.",
			"💬",
			Color(0.2, 0.7, 0.9)
		),
		"collaboration": CompetencyDef.new(
			"collaboration",
			"Collaboration",
			"Colaboração",
			"Habilidade de trabalhar efetivamente em equipe e contribuir para objetivos comuns.",
			"🤝",
			Color(0.3, 0.8, 0.5)
		),
		"digital_ethics": CompetencyDef.new(
			"digital_ethics",
			"Digital Ethics",
			"Ética Digital",
			"Compreensão do uso responsável e ético de tecnologia e inteligência artificial.",
			"⚖️",
			Color(0.8, 0.7, 0.3)
		),
		"logic": CompetencyDef.new(
			"logic",
			"Logic",
			"Lógica",
			"Capacidade de raciocinar de forma estruturada e resolver problemas sistemicamente.",
			"🔢",
			Color(0.5, 0.5, 0.9)
		),
		"problem_solving": CompetencyDef.new(
			"problem_solving",
			"Problem Solving",
			"Resolução de Problemas",
			"Habilidade de identificar problemas e desenvolver estratégias eficazes para resolvê-los.",
			"🔧",
			Color(0.9, 0.4, 0.4)
		)
	}


func _setup_levels() -> void:
	level_thresholds = [
		LevelDef.new(1, "Iniciante", 0, 9),
		LevelDef.new(2, "Aprendiz", 10, 24),
		LevelDef.new(3, "Praticante", 25, 44),
		LevelDef.new(4, "Competente", 45, 69),
		LevelDef.new(5, "Proficiente", 70, 89),
		LevelDef.new(6, "Mestre", 90, 100)
	]


func _setup_achievements() -> void:
	achievements = {
		"first_critical_thinking": {
			"id": "first_critical_thinking",
			"name": "Primeiro Passo do Pensador",
			"description": "Desenvolveu sua primeira habilidade de pensamento crítico",
			"competency": "critical_thinking",
			"threshold": 5,
			"icon": "🎯"
		},
		"creative_spark": {
			"id": "creative_spark",
			"name": "Faísca Criativa",
			"description": "Mostrou sinais de criatividade brilhante",
			"competency": "creativity",
			"threshold": 10,
			"icon": "✨"
		},
		"good_communicator": {
			"id": "good_communicator",
			"name": "Bom Comunicador",
			"description": "Demonstrou habilidades de comunicação eficaz",
			"competency": "communication",
			"threshold": 15,
			"icon": "🎤"
		},
		"team_player": {
			"id": "team_player",
			"name": "Jogador de Equipe",
			"description": "Provou ser um excelente colaborador",
			"competency": "collaboration",
			"threshold": 15,
			"icon": "👥"
		},
		"ethical_mind": {
			"id": "ethical_mind",
			"name": "Mente Ética",
			"description": "Entende a importância da ética digital",
			"competency": "digital_ethics",
			"threshold": 10,
			"icon": "🌟"
		},
		"logic_master": {
			"id": "logic_master",
			"name": "Lógico Iniciante",
			"description": "Começou a dominar o pensamento lógico",
			"competency": "logic",
			"threshold": 10,
			"icon": "🧩"
		},
		"problem_solver": {
			"id": "problem_solver",
			"name": "Solucionador de Problemas",
			"description": "Resolveu seu primeiro grande desafio",
			"competency": "problem_solving",
			"threshold": 10,
			"icon": "🔍"
		},
		"well_rounded": {
			"id": "well_rounded",
			"name": "Equilibrado",
			"description": "Desenvolveu todas as competências para nível 2",
			"type": "all_competencies",
			"threshold": 10,
			"icon": "🌈"
		},
		"aria_friend": {
			"id": "aria_friend",
			"name": "Amigo da ARIA",
			"description": "Usou a ARIA 10 vezes para aprender",
			"type": "aria_usage",
			"threshold": 10,
			"icon": "🤖"
		}
	}


# ===========================================
# Competency Access
# ===========================================

func get_competency_def(type: String) -> CompetencyDef:
	return competency_defs.get(type, null)


func get_all_competencies() -> Dictionary:
	return competency_defs


func get_competency_value(type: String) -> int:
	return GameManager.get_competency(type)


func get_competency_level(type: String) -> int:
	var points := get_competency_value(type)
	return _points_to_level(points)


func get_level_name(level: int) -> String:
	for level_def in level_thresholds:
		if level_def.level == level:
			return level_def.name
	return "Desconhecido"


func get_level_for_points(points: int) -> LevelDef:
	for level_def in level_thresholds:
		if points >= level_def.min_points and points <= level_def.max_points:
			return level_def
	return level_thresholds[-1]  # Return max level if over 100


func _points_to_level(points: int) -> int:
	for level_def in level_thresholds:
		if points >= level_def.min_points and points <= level_def.max_points:
			return level_def.level
	return level_thresholds[-1].level


# ===========================================
# Competency Modification
# ===========================================

func add_competency(type: String, amount: int) -> void:
	if not competency_defs.has(type):
		push_warning("[CompetencyManager] Unknown competency type: %s" % type)
		return

	var old_value := get_competency_value(type)
	var old_level := _points_to_level(old_value)

	GameManager.add_competency(type, amount)

	var new_value := get_competency_value(type)
	var new_level := _points_to_level(new_value)

	if new_value != old_value:
		competency_updated.emit(type, old_value, new_value)

		if new_level > old_level:
			competency_level_up.emit(type, new_level)
			print("[CompetencyManager] Level up! %s -> Level %d (%s)" % [
				type, new_level, get_level_name(new_level)
			])

		# Check achievements
		_check_achievements(type, new_value)


# ===========================================
# Progress Calculation
# ===========================================

func get_progress_in_level(type: String) -> float:
	var points := get_competency_value(type)
	var level_def := get_level_for_points(points)

	var level_range := level_def.max_points - level_def.min_points + 1
	var progress_in_level := points - level_def.min_points

	return float(progress_in_level) / float(level_range)


func get_points_to_next_level(type: String) -> int:
	var points := get_competency_value(type)
	var level_def := get_level_for_points(points)

	if level_def.level >= level_thresholds[-1].level:
		return 0  # Already at max level

	return level_def.max_points - points + 1


func get_total_competency_points() -> int:
	var total := 0
	for comp_type in competency_defs:
		total += get_competency_value(comp_type)
	return total


func get_average_level() -> float:
	var total_levels := 0.0
	for comp_type in competency_defs:
		total_levels += get_competency_level(comp_type)
	return total_levels / float(competency_defs.size())


# ===========================================
# Achievements
# ===========================================

func _check_achievements(updated_type: String, new_value: int) -> void:
	for ach_id in achievements:
		var ach: Dictionary = achievements[ach_id]

		# Skip already unlocked
		if GameManager.has_flag("achievement_" + ach_id):
			continue

		var unlocked := false

		if ach.has("competency"):
			# Single competency achievement
			if ach["competency"] == updated_type and new_value >= ach["threshold"]:
				unlocked = true
		elif ach.get("type") == "all_competencies":
			# Check if all competencies meet threshold
			unlocked = true
			for comp_type in competency_defs:
				if get_competency_value(comp_type) < ach["threshold"]:
					unlocked = false
					break

		if unlocked:
			_unlock_achievement(ach_id)


func _unlock_achievement(achievement_id: String) -> void:
	GameManager.set_flag("achievement_" + achievement_id, true)
	achievement_unlocked.emit(achievement_id)

	var ach: Dictionary = achievements[achievement_id]
	print("[CompetencyManager] Achievement unlocked: %s - %s" % [ach["icon"], ach["name"]])


func get_achievement(achievement_id: String) -> Dictionary:
	return achievements.get(achievement_id, {})


func get_unlocked_achievements() -> Array[String]:
	var unlocked: Array[String] = []
	for ach_id in achievements:
		if GameManager.has_flag("achievement_" + ach_id):
			unlocked.append(ach_id)
	return unlocked


func get_locked_achievements() -> Array[String]:
	var locked: Array[String] = []
	for ach_id in achievements:
		if not GameManager.has_flag("achievement_" + ach_id):
			locked.append(ach_id)
	return locked


# ===========================================
# Competency Requirements
# ===========================================

func meets_requirement(type: String, min_level: int) -> bool:
	return get_competency_level(type) >= min_level


func meets_requirements(requirements: Dictionary) -> bool:
	for comp_type in requirements:
		if not meets_requirement(comp_type, requirements[comp_type]):
			return false
	return true


func get_unmet_requirements(requirements: Dictionary) -> Dictionary:
	var unmet := {}
	for comp_type in requirements:
		if not meets_requirement(comp_type, requirements[comp_type]):
			unmet[comp_type] = {
				"required": requirements[comp_type],
				"current": get_competency_level(comp_type)
			}
	return unmet


# ===========================================
# Summary & Display
# ===========================================

func get_competency_summary() -> Array[Dictionary]:
	var summary: Array[Dictionary] = []

	for comp_type in competency_defs:
		var comp_def: CompetencyDef = competency_defs[comp_type]
		var points := get_competency_value(comp_type)
		var level := get_competency_level(comp_type)
		var progress := get_progress_in_level(comp_type)

		summary.append({
			"id": comp_type,
			"name": comp_def.name_pt,
			"icon": comp_def.icon,
			"color": comp_def.color,
			"points": points,
			"level": level,
			"level_name": get_level_name(level),
			"progress": progress,
			"to_next": get_points_to_next_level(comp_type)
		})

	return summary


func get_top_competencies(count: int = 3) -> Array[Dictionary]:
	var all_comps := get_competency_summary()

	# Sort by points descending
	all_comps.sort_custom(func(a, b): return a["points"] > b["points"])

	return all_comps.slice(0, count)


func get_weakest_competencies(count: int = 3) -> Array[Dictionary]:
	var all_comps := get_competency_summary()

	# Sort by points ascending
	all_comps.sort_custom(func(a, b): return a["points"] < b["points"])

	return all_comps.slice(0, count)
