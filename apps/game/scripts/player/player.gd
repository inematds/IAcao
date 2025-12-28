extends CharacterBody2D
## Player - Controlador do personagem jogável
##
## Responsável por:
## - Movimento do jogador
## - Detecção de interações
## - Animações (futuro)

# Constants
const SPEED := 200.0
const ACCELERATION := 1200.0
const FRICTION := 1000.0

# State
var facing_direction := Vector2.DOWN
var can_move := true
var is_interacting := false

# Interaction
var nearby_interactables: Array[Node2D] = []

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("player")
	GameManager.game_state_changed.connect(_on_game_state_changed)
	print("[Player] Ready at position: ", position)


func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		move_and_slide()
		return

	var input_direction := _get_input_direction()

	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * SPEED, ACCELERATION * delta)
		facing_direction = input_direction.normalized()
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_move:
		_try_interact()


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


func resume_movement() -> void:
	can_move = true


# ===========================================
# Interaction
# ===========================================

func _try_interact() -> void:
	if nearby_interactables.is_empty():
		return

	# Get closest interactable
	var closest: Node2D = null
	var closest_distance := INF

	for interactable in nearby_interactables:
		var distance := position.distance_to(interactable.position)
		if distance < closest_distance:
			closest = interactable
			closest_distance = distance

	if closest and closest.has_method("interact"):
		print("[Player] Interacting with: ", closest.name)
		is_interacting = true
		stop_movement()
		closest.interact(self)


func end_interaction() -> void:
	is_interacting = false
	resume_movement()


func register_interactable(interactable: Node2D) -> void:
	if not nearby_interactables.has(interactable):
		nearby_interactables.append(interactable)


func unregister_interactable(interactable: Node2D) -> void:
	nearby_interactables.erase(interactable)


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
