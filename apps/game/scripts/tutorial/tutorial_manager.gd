extends Node
class_name TutorialManager
## TutorialManager - Gerenciador do sistema de tutorial e onboarding
##
## Responsável por:
## - Tutorial integrado à narrativa
## - Tooltips contextuais
## - Introdução gradual de mecânicas
## - Checklist de aprendizado

# Signals
signal tutorial_started(step_id: String)
signal tutorial_step_completed(step_id: String)
signal tutorial_completed()
signal hint_shown(hint_id: String)
signal hint_hidden(hint_id: String)

# Tutorial steps
enum TutorialStep {
	NONE,
	INTRO,           # Introdução ao jogo
	MOVEMENT,        # Aprender a se mover
	INTERACT_NPC,    # Interagir com NPC
	DIALOGUE_CHOICE, # Fazer escolha em diálogo
	OPEN_ARIA,       # Abrir painel da ARIA
	USE_ARIA,        # Usar uma ação da ARIA
	CHECK_COMPETENCY,# Ver competências
	CHECK_MISSIONS,  # Ver missões
	SAVE_GAME,       # Salvar o jogo
	COMPLETE         # Tutorial completo
}

# Step data structure
class TutorialStepData:
	var id: String
	var step: TutorialStep
	var title: String
	var description: String
	var hint_text: String
	var trigger_condition: String
	var required: bool = true
	var completed: bool = false

	func _init(i: String, s: TutorialStep, t: String, d: String, h: String, tc: String = "", req: bool = true) -> void:
		id = i
		step = s
		title = t
		description = d
		hint_text = h
		trigger_condition = tc
		required = req

# State
var is_tutorial_active := false
var current_step: TutorialStep = TutorialStep.NONE
var completed_steps: Array[String] = []
var tutorial_steps: Dictionary = {}  # id -> TutorialStepData
var active_hints: Array[String] = []

# Settings
var show_hints := true
var hint_delay := 5.0  # Seconds before showing hint

# Hint timer
var hint_timer: Timer

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	_define_tutorial_steps()
	_setup_hint_timer()

	# Connect to signals from other managers
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.choice_made.connect(_on_choice_made)
	ARIAManager.aria_opened.connect(_on_aria_opened)
	ARIAManager.action_completed.connect(_on_aria_action_completed)
	MissionManager.mission_completed.connect(_on_mission_completed)

	print("[TutorialManager] Initialized")


func _setup_hint_timer() -> void:
	hint_timer = Timer.new()
	hint_timer.one_shot = true
	hint_timer.timeout.connect(_on_hint_timer)
	add_child(hint_timer)


func _define_tutorial_steps() -> void:
	var steps: Array[TutorialStepData] = [
		TutorialStepData.new(
			"intro",
			TutorialStep.INTRO,
			"Bem-vindo a Vila Esperança!",
			"Você acaba de chegar em uma nova vila. Vamos explorar juntos!",
			"Pressione as setas ou WASD para se mover",
			"game_started"
		),
		TutorialStepData.new(
			"movement",
			TutorialStep.MOVEMENT,
			"Explorar a Vila",
			"Use as setas ou WASD para se mover pelo cenário.",
			"Use ↑↓←→ ou WASD para andar",
			"player_moved"
		),
		TutorialStepData.new(
			"interact_npc",
			TutorialStep.INTERACT_NPC,
			"Conhecer os Habitantes",
			"Aproxime-se de uma pessoa e pressione E para conversar.",
			"Pressione E perto de um NPC para conversar",
			"npc_interacted"
		),
		TutorialStepData.new(
			"dialogue_choice",
			TutorialStep.DIALOGUE_CHOICE,
			"Fazer Escolhas",
			"Durante conversas, você pode fazer escolhas que afetam a história.",
			"Clique em uma opção para escolher",
			"choice_made"
		),
		TutorialStepData.new(
			"open_aria",
			TutorialStep.OPEN_ARIA,
			"Conhecer ARIA",
			"ARIA é sua assistente de IA. Pressione Q para abrir o painel dela.",
			"Pressione Q para abrir ARIA",
			"aria_opened"
		),
		TutorialStepData.new(
			"use_aria",
			TutorialStep.USE_ARIA,
			"Usar ARIA",
			"Use uma das ações de ARIA para receber ajuda.",
			"Escolha uma ação: Analisar, Sugerir, Simular ou Melhorar",
			"aria_action_used"
		),
		TutorialStepData.new(
			"check_competency",
			TutorialStep.CHECK_COMPETENCY,
			"Ver suas Competências",
			"Pressione C para ver suas competências e progresso.",
			"Pressione C para ver competências",
			"competency_opened",
			false  # Opcional
		),
		TutorialStepData.new(
			"check_missions",
			TutorialStep.CHECK_MISSIONS,
			"Ver Missões",
			"Pressione M para ver suas missões e objetivos.",
			"Pressione M para ver missões",
			"missions_opened",
			false  # Opcional
		),
		TutorialStepData.new(
			"save_game",
			TutorialStep.SAVE_GAME,
			"Salvar Progresso",
			"O jogo salva automaticamente, mas você pode salvar manualmente com ESC > Salvar.",
			"Pressione ESC para abrir o menu",
			"game_saved",
			false  # Opcional
		)
	]

	for step in steps:
		tutorial_steps[step.id] = step


# ===========================================
# Tutorial Control
# ===========================================

func start_tutorial() -> void:
	if is_tutorial_active:
		return

	is_tutorial_active = true
	current_step = TutorialStep.INTRO

	# Start with intro step
	_activate_step("intro")
	tutorial_started.emit("intro")

	print("[Tutorial] Started")


func skip_tutorial() -> void:
	if not is_tutorial_active:
		return

	# Mark all required steps as completed
	for step_id in tutorial_steps:
		var step: TutorialStepData = tutorial_steps[step_id]
		if step.required:
			step.completed = true
			completed_steps.append(step_id)

	is_tutorial_active = false
	current_step = TutorialStep.COMPLETE

	tutorial_completed.emit()
	print("[Tutorial] Skipped")


func complete_step(step_id: String) -> void:
	if not tutorial_steps.has(step_id):
		return

	var step: TutorialStepData = tutorial_steps[step_id]
	if step.completed:
		return

	step.completed = true
	completed_steps.append(step_id)

	hide_hint(step_id)
	tutorial_step_completed.emit(step_id)

	print("[Tutorial] Step completed: %s" % step_id)

	# Check if tutorial is complete
	_check_tutorial_completion()

	# Move to next step
	_activate_next_step()


func is_step_completed(step_id: String) -> bool:
	return completed_steps.has(step_id)


func get_current_step_data() -> TutorialStepData:
	for step_id in tutorial_steps:
		var step: TutorialStepData = tutorial_steps[step_id]
		if step.step == current_step:
			return step
	return null


func get_completed_count() -> int:
	return completed_steps.size()


func get_total_required_steps() -> int:
	var count := 0
	for step_id in tutorial_steps:
		var step: TutorialStepData = tutorial_steps[step_id]
		if step.required:
			count += 1
	return count


# ===========================================
# Step Activation
# ===========================================

func _activate_step(step_id: String) -> void:
	if not tutorial_steps.has(step_id):
		return

	var step: TutorialStepData = tutorial_steps[step_id]
	current_step = step.step

	# Start hint timer
	if show_hints:
		hint_timer.start(hint_delay)

	print("[Tutorial] Activated step: %s" % step_id)


func _activate_next_step() -> void:
	var next_step := current_step + 1

	while next_step < TutorialStep.COMPLETE:
		var found := false
		for step_id in tutorial_steps:
			var step: TutorialStepData = tutorial_steps[step_id]
			if step.step == next_step and not step.completed:
				_activate_step(step_id)
				found = true
				break

		if found:
			break

		next_step += 1

	if next_step >= TutorialStep.COMPLETE:
		_check_tutorial_completion()


func _check_tutorial_completion() -> void:
	var all_required_complete := true

	for step_id in tutorial_steps:
		var step: TutorialStepData = tutorial_steps[step_id]
		if step.required and not step.completed:
			all_required_complete = false
			break

	if all_required_complete and is_tutorial_active:
		is_tutorial_active = false
		current_step = TutorialStep.COMPLETE
		tutorial_completed.emit()

		# Set world flag
		GameManager.set_flag("tutorial_completed", true)

		print("[Tutorial] Completed!")


# ===========================================
# Hints
# ===========================================

func show_hint(hint_id: String) -> void:
	if not show_hints:
		return

	if active_hints.has(hint_id):
		return

	active_hints.append(hint_id)
	hint_shown.emit(hint_id)

	print("[Tutorial] Hint shown: %s" % hint_id)


func hide_hint(hint_id: String) -> void:
	if not active_hints.has(hint_id):
		return

	active_hints.erase(hint_id)
	hint_hidden.emit(hint_id)


func get_current_hint() -> String:
	var step := get_current_step_data()
	if step:
		return step.hint_text
	return ""


func _on_hint_timer() -> void:
	var step := get_current_step_data()
	if step and not step.completed:
		show_hint(step.id)


# ===========================================
# Event Handlers
# ===========================================

func _on_dialogue_started(_npc_id: String) -> void:
	if current_step == TutorialStep.INTERACT_NPC:
		complete_step("interact_npc")


func _on_dialogue_ended(_npc_id: String) -> void:
	pass


func _on_choice_made(_choice_id: String, _choice_data: Dictionary) -> void:
	if current_step == TutorialStep.DIALOGUE_CHOICE:
		complete_step("dialogue_choice")


func _on_aria_opened() -> void:
	if current_step == TutorialStep.OPEN_ARIA:
		complete_step("open_aria")


func _on_aria_action_completed(_action: ARIAManager.ARIAAction, _response: String) -> void:
	if current_step == TutorialStep.USE_ARIA:
		complete_step("use_aria")


func _on_mission_completed(_mission_id: String) -> void:
	# Tutorial missions
	if _mission_id == "tutorial_welcome":
		GameManager.set_flag("tutorial_aria", true)


# ===========================================
# Input Detection
# ===========================================

func _input(event: InputEvent) -> void:
	if not is_tutorial_active:
		return

	# Detect movement
	if current_step == TutorialStep.MOVEMENT:
		if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") or \
		   event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
			# Complete after a short delay to allow player to move
			await get_tree().create_timer(1.0).timeout
			complete_step("movement")


# ===========================================
# Progress Checklist
# ===========================================

func get_checklist() -> Array[Dictionary]:
	var checklist: Array[Dictionary] = []

	for step_id in tutorial_steps:
		var step: TutorialStepData = tutorial_steps[step_id]
		checklist.append({
			"id": step.id,
			"title": step.title,
			"completed": step.completed,
			"required": step.required
		})

	return checklist


# ===========================================
# Serialization
# ===========================================

func save_data() -> Dictionary:
	return {
		"is_active": is_tutorial_active,
		"current_step": current_step,
		"completed_steps": completed_steps
	}


func load_data(data: Dictionary) -> void:
	is_tutorial_active = data.get("is_active", false)
	current_step = data.get("current_step", TutorialStep.NONE) as TutorialStep
	completed_steps = data.get("completed_steps", [])

	# Restore step completion state
	for step_id in completed_steps:
		if tutorial_steps.has(step_id):
			tutorial_steps[step_id].completed = true
