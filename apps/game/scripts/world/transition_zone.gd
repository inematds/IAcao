extends Area2D
class_name TransitionZone
## TransitionZone - Zona de transição entre áreas
##
## Quando o jogador entra nesta zona, solicita transição para outra área

@export var target_area: String = ""
@export var target_spawn: String = "default"
@export var auto_transition: bool = true
@export var requires_interaction: bool = false

var player_in_zone: bool = false

# ===========================================
# Lifecycle
# ===========================================

func _ready() -> void:
	add_to_group("transitions")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if requires_interaction and player_in_zone:
		if event.is_action_pressed("interact"):
			_trigger_transition()


# ===========================================
# Detection
# ===========================================

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		if auto_transition and not requires_interaction:
			_trigger_transition()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_zone = false


# ===========================================
# Transition
# ===========================================

func _trigger_transition() -> void:
	if target_area == "":
		push_warning("[TransitionZone] No target area set")
		return

	print("[TransitionZone] Transitioning to: %s (spawn: %s)" % [target_area, target_spawn])

	# Find parent area and request transition
	var area := _find_parent_area()
	if area:
		area.request_transition(target_area, target_spawn)
	else:
		# Fallback: emit signal via SceneManager
		SceneManager.change_area(target_area, target_spawn)


func _find_parent_area() -> AreaBase:
	var parent := get_parent()
	while parent:
		if parent is AreaBase:
			return parent
		parent = parent.get_parent()
	return null
