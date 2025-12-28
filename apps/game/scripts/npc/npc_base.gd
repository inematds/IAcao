extends CharacterBody2D
class_name NPCBase
## NPCBase - Base class for all NPCs
##
## Provides:
## - Basic movement and idle behavior
## - Interaction detection
## - Dialogue triggering

# Signals
signal interaction_started(player: Node2D)
signal interaction_ended()
signal dialogue_requested(dialogue_id: String)

# NPC Info
@export var npc_id: String = ""
@export var npc_name: String = "NPC"
@export var dialogue_id: String = ""

# Visual
@export var body_color: Color = Color(0.6, 0.5, 0.4, 1)
@export var shirt_color: Color = Color(0.4, 0.5, 0.6, 1)

# Behavior
@export var can_move: bool = true
@export var wander_enabled: bool = true
@export var wander_radius: float = 100.0
@export var wander_speed: float = 50.0
@export var idle_time_min: float = 2.0
@export var idle_time_max: float = 5.0

# State
enum State { IDLE, WANDERING, TALKING, LOOKING }
var current_state: State = State.IDLE
var home_position: Vector2
var wander_target: Vector2
var facing_direction := Vector2.DOWN
var idle_timer := 0.0
var look_timer := 0.0

# Interaction
var player_nearby := false
var interacting_player: Node2D = null

# Nodes
@onready var body: ColorRect = $Body
@onready var head: ColorRect = $Head
@onready var interaction_area: Area2D = $InteractionArea
@onready var indicator: Label = $Indicator

# Animation
var bob_time := 0.0

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("npcs")
	home_position = position

	_setup_visuals()
	_connect_signals()

	# Start with idle
	_start_idle()

	print("[NPC] %s ready at %s" % [npc_name, position])


func _setup_visuals() -> void:
	if body:
		body.color = shirt_color
	if head:
		head.color = body_color

	if indicator:
		indicator.visible = false


func _connect_signals() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.WANDERING:
			_process_wandering(delta)
		State.TALKING:
			_process_talking(delta)
		State.LOOKING:
			_process_looking(delta)

	_update_animation(delta)


# ===========================================
# States
# ===========================================

func _start_idle() -> void:
	current_state = State.IDLE
	velocity = Vector2.ZERO
	idle_timer = randf_range(idle_time_min, idle_time_max)


func _process_idle(delta: float) -> void:
	idle_timer -= delta

	if idle_timer <= 0:
		if wander_enabled and can_move:
			_start_wandering()
		else:
			_start_looking()


func _start_wandering() -> void:
	current_state = State.WANDERING

	# Pick random point within wander radius
	var angle := randf() * TAU
	var distance := randf_range(wander_radius * 0.3, wander_radius)
	wander_target = home_position + Vector2(cos(angle), sin(angle)) * distance


func _process_wandering(delta: float) -> void:
	var direction := (wander_target - position).normalized()
	velocity = direction * wander_speed
	facing_direction = direction

	move_and_slide()

	# Check if reached target
	if position.distance_to(wander_target) < 10:
		_start_idle()


func _start_looking() -> void:
	current_state = State.LOOKING
	look_timer = randf_range(1.0, 3.0)


func _process_looking(delta: float) -> void:
	look_timer -= delta

	if look_timer <= 0:
		# Randomly change facing direction
		var directions := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
		facing_direction = directions[randi() % directions.size()]
		_start_idle()


func _start_talking(player: Node2D) -> void:
	current_state = State.TALKING
	velocity = Vector2.ZERO
	interacting_player = player

	# Face the player
	facing_direction = (player.position - position).normalized()

	interaction_started.emit(player)


func _process_talking(delta: float) -> void:
	# Keep facing player
	if interacting_player:
		facing_direction = (interacting_player.position - position).normalized()


func _end_talking() -> void:
	interacting_player = null
	interaction_ended.emit()
	_start_idle()


# ===========================================
# Animation
# ===========================================

func _update_animation(delta: float) -> void:
	var is_moving := current_state == State.WANDERING

	if is_moving:
		# Walking bob
		bob_time += delta * 10.0
		var bob := sin(bob_time) * 1.5
		if body:
			body.position.y = bob
		if head:
			head.position.y = bob * 0.5
	else:
		# Idle breathing
		bob_time += delta * 2.0
		var breathe := sin(bob_time) * 0.3
		if body:
			body.position.y = breathe
		if head:
			head.position.y = breathe * 0.2


# ===========================================
# Interaction
# ===========================================

func _on_body_entered(body_node: Node2D) -> void:
	if body_node.is_in_group("player"):
		player_nearby = true
		_show_indicator()

		if body_node.has_method("register_interactable"):
			body_node.register_interactable(self)


func _on_body_exited(body_node: Node2D) -> void:
	if body_node.is_in_group("player"):
		player_nearby = false
		_hide_indicator()

		if body_node.has_method("unregister_interactable"):
			body_node.unregister_interactable(self)


func interact(player: Node2D) -> void:
	print("[NPC] %s interacted by player" % npc_name)
	_start_talking(player)

	if dialogue_id != "":
		dialogue_requested.emit(dialogue_id)
		# Start dialogue through DialogueManager
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
		DialogueManager.start_dialogue(dialogue_id)
	else:
		# Default: just say something
		_default_dialogue()


func _default_dialogue() -> void:
	print("[NPC] %s: Olá!" % npc_name)
	# Brief delay before ending
	await get_tree().create_timer(1.5).timeout
	end_interaction()


func _on_dialogue_ended(id: String) -> void:
	end_interaction()


func end_interaction() -> void:
	if interacting_player and interacting_player.has_method("end_interaction"):
		interacting_player.end_interaction()
	_end_talking()


func _show_indicator() -> void:
	if indicator:
		var display_text := npc_name

		# Add relationship indicator if player has met this NPC
		if npc_id != "" and DialogueManager.has_met_npc(npc_id):
			var rel_level := DialogueManager.get_relationship_level_with(npc_id)
			var heart := _get_relationship_icon(rel_level)
			if heart != "":
				display_text = "%s %s" % [heart, npc_name]

		indicator.text = display_text
		indicator.visible = true


func _hide_indicator() -> void:
	if indicator:
		indicator.visible = false


func _get_relationship_icon(level: int) -> String:
	match level:
		NPCMemory.RelationshipLevel.BEST_FRIEND:
			return "💖"
		NPCMemory.RelationshipLevel.CLOSE_FRIEND:
			return "❤️"
		NPCMemory.RelationshipLevel.FRIEND:
			return "💛"
		NPCMemory.RelationshipLevel.ACQUAINTANCE:
			return "💙"
		_:
			return ""


# ===========================================
# Utilities
# ===========================================

func set_dialogue(id: String) -> void:
	dialogue_id = id


func teleport_to(new_position: Vector2) -> void:
	position = new_position
	home_position = new_position


func stop_wandering() -> void:
	wander_enabled = false
	if current_state == State.WANDERING:
		_start_idle()


func resume_wandering() -> void:
	wander_enabled = true
