extends CharacterBody2D
## Player - Controlador do personagem jogável
##
## Responsável por:
## - Movimento do jogador (teclado e click-to-move)
## - Detecção de interações
## - Animações de movimento
## - Indicador de interação

# Constants
const SPEED := 180.0
const ACCELERATION := 1400.0
const FRICTION := 1200.0
const CLICK_MOVE_THRESHOLD := 10.0

# State
var facing_direction := Vector2.DOWN
var can_move := true
var is_interacting := false
var click_target: Vector2 = Vector2.ZERO
var is_click_moving := false

# Interaction
var nearby_interactables: Array[Node2D] = []

# Node references
@onready var body: ColorRect = $Body
@onready var head: ColorRect = $Head
@onready var shadow: ColorRect = $Shadow
@onready var interaction_indicator: Label = $InteractionIndicator
@onready var camera: Camera2D = $Camera2D

# Animation
var bob_time := 0.0
var original_body_y := 0.0
var original_head_y := 0.0

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("player")
	GameManager.game_state_changed.connect(_on_game_state_changed)

	# Store original positions for animation
	original_body_y = body.offset_top
	original_head_y = head.offset_top

	print("[Player] Ready at position: ", position)


func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		move_and_slide()
		_update_animation(delta, false)
		return

	var input_direction := _get_input_direction()

	# Click-to-move handling
	if is_click_moving:
		var distance := position.distance_to(click_target)
		if distance < CLICK_MOVE_THRESHOLD:
			is_click_moving = false
		else:
			input_direction = (click_target - position).normalized()

	# Apply movement
	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * SPEED, ACCELERATION * delta)
		facing_direction = input_direction.normalized()
		_update_animation(delta, true)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		_update_animation(delta, false)

	move_and_slide()
	_update_interaction_indicator()


func _input(event: InputEvent) -> void:
	if not can_move:
		return

	# Keyboard interaction
	if event.is_action_pressed("interact"):
		_try_interact()

	# Click-to-move
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			click_target = get_global_mouse_position()
			is_click_moving = true
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Right-click cancels movement
			is_click_moving = false


func _unhandled_input(event: InputEvent) -> void:
	# Cancel click movement on any keyboard movement
	if event.is_action_pressed("move_up") or event.is_action_pressed("move_down") \
	   or event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		is_click_moving = false


# ===========================================
# Movement
# ===========================================

func _get_input_direction() -> Vector2:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return Vector2.ZERO

	var direction := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	return direction.normalized()


func stop_movement() -> void:
	can_move = false
	velocity = Vector2.ZERO
	is_click_moving = false


func resume_movement() -> void:
	can_move = true


# ===========================================
# Animation
# ===========================================

func _update_animation(delta: float, is_moving: bool) -> void:
	if is_moving:
		# Walking bob animation
		bob_time += delta * 12.0
		var bob_offset := sin(bob_time) * 2.0
		body.offset_top = original_body_y + bob_offset
		head.offset_top = original_head_y + bob_offset * 0.5

		# Slight squash/stretch
		var squash := 1.0 + sin(bob_time * 2.0) * 0.03
		body.scale.y = squash
		head.scale.y = squash
	else:
		# Idle - gentle breathing
		bob_time += delta * 2.0
		var breathe := sin(bob_time) * 0.5
		body.offset_top = original_body_y + breathe
		head.offset_top = original_head_y + breathe * 0.3

		# Reset scale
		body.scale.y = 1.0
		head.scale.y = 1.0

	# Update body color based on facing direction (simple directional indicator)
	_update_facing_visuals()


func _update_facing_visuals() -> void:
	# Slight color shift based on direction for visual feedback
	var base_color := Color(0.2, 0.6, 0.9, 1)

	if facing_direction.y < -0.5:  # Up
		body.color = base_color.darkened(0.1)
	elif facing_direction.y > 0.5:  # Down
		body.color = base_color
	elif facing_direction.x < -0.5:  # Left
		body.color = base_color.darkened(0.05)
	elif facing_direction.x > 0.5:  # Right
		body.color = base_color.lightened(0.05)


# ===========================================
# Interaction
# ===========================================

func _try_interact() -> void:
	if nearby_interactables.is_empty():
		return

	# Get closest interactable in facing direction
	var best_target: Node2D = null
	var best_score := -INF

	for interactable in nearby_interactables:
		var to_interactable := (interactable.position - position).normalized()
		var dot := facing_direction.dot(to_interactable)
		var distance := position.distance_to(interactable.position)

		# Score based on direction alignment and distance
		var score := dot * 100.0 - distance * 0.1

		if score > best_score:
			best_score = score
			best_target = interactable

	if best_target and best_target.has_method("interact"):
		print("[Player] Interacting with: ", best_target.name)
		is_interacting = true
		stop_movement()
		best_target.interact(self)


func end_interaction() -> void:
	is_interacting = false
	resume_movement()


func register_interactable(interactable: Node2D) -> void:
	if not nearby_interactables.has(interactable):
		nearby_interactables.append(interactable)
		_update_interaction_indicator()


func unregister_interactable(interactable: Node2D) -> void:
	nearby_interactables.erase(interactable)
	_update_interaction_indicator()


func _update_interaction_indicator() -> void:
	if nearby_interactables.size() > 0 and can_move:
		interaction_indicator.visible = true
	else:
		interaction_indicator.visible = false


# ===========================================
# Signal Handlers
# ===========================================

func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	match new_state:
		GameManager.GameState.DIALOGUE, GameManager.GameState.CUTSCENE:
			stop_movement()
		GameManager.GameState.PLAYING:
			if not is_interacting:
				resume_movement()


# ===========================================
# Utility
# ===========================================

func get_facing_direction() -> Vector2:
	return facing_direction


func get_facing_name() -> String:
	if abs(facing_direction.x) > abs(facing_direction.y):
		return "right" if facing_direction.x > 0 else "left"
	else:
		return "down" if facing_direction.y > 0 else "up"


func teleport_to(new_position: Vector2) -> void:
	position = new_position
	velocity = Vector2.ZERO
	is_click_moving = false
